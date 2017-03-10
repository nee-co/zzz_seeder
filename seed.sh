#!/bin/bash

rm tmp/*

HOST=${HOST:="https://api.neec.ooo"}
# HOST=${HOST:="http://api.127.0.0.1.nip.io"}
echo ${HOST}

# User
for user_num in $(seq 1 10)
do
  echo -n "ユーザ${user_num} トークン作成 トークン="

  time curl -sS -X POST ${HOST}/token \
       --data "number=$(q -H -d, "SELECT number FROM users/users.csv LIMIT 1 OFFSET $(expr ${user_num} - 1)")" \
       --data "password=$(q -H -d, "SELECT password FROM users/users.csv LIMIT 1 OFFSET $(expr ${user_num} - 1)")" \
  | jq -r .token | tee tmp/token${user_num}

  echo -n "ユーザ${user_num} ID="
  time curl -sS -X GET ${HOST}/user -H "Authorization: Bearer $(cat tmp/token${user_num})" | jq -r .id | tee tmp/user${user_num}_id
done

# Event
echo -n "イベント1作成 オーナー=ユーザ1 公開 ID="
time curl -sS -X POST ${HOST}/events \
     -H "Authorization: Bearer $(cat tmp/token1)" \
     -F "title=androidもくもく会" \
     -F "body=<${PWD}/texts/android.md" \
     -F "start_date=2018-01-01" \
     -F "image=@${PWD}/images/kong.png" \
| jq -r .id | tee tmp/event1
time curl -X PUT ${HOST}/events/$(cat tmp/event1)/public -H "Authorization: Bearer $(cat tmp/token1)"

echo "イベント1 適当にコメント"
time curl -X POST ${HOST}/events/$(cat tmp/event1)/comments -H "Authorization: Bearer $(cat tmp/token1)" -d 'body=こんにちわ'
time curl -X POST ${HOST}/events/$(cat tmp/event1)/comments -H "Authorization: Bearer $(cat tmp/token2)" -d 'body=ヤッホー'

for user_num in $(seq 2 8)
do
  echo "イベント1 user${user_num}参加"
  time curl -X PUT ${HOST}/events/$(cat tmp/event1)/entry -H "Authorization: Bearer $(cat tmp/token${user_num})"
done

echo -n "イベント2作成 オーナー=ユーザ1 非公開 ID="
time curl -sS -X POST ${HOST}/events \
     -H "Authorization: Bearer $(cat tmp/token1)" \
     -F "title=非公開androidもくもく会" \
     -F "body=<${PWD}/texts/markdown.md" \
     -F "start_date=2018-01-01" \
     -F "image=@${PWD}/images/kong.gif" \
| jq -r .id | tee tmp/event2

for event_num in $(seq 3 20)
do
  echo -n "イベント${event_num}作成 オーナー=ユーザ2 公開 ID="
  time curl -sS -X POST ${HOST}/events \
       -H "Authorization: Bearer $(cat tmp/token2)" \
       -F "title=もくもく会#${event_num}" \
       -F "body=<${PWD}/texts/markdown.md" \
       -F "start_date=2018-01-${event_num}" \
       -F "image=@${PWD}/images/kong2.png" \
  | jq -r .id | tee tmp/event${event_num}
  time curl -X PUT ${HOST}/events/$(cat tmp/event${event_num})/public -H "Authorization: Bearer $(cat tmp/token2)"

  if [ `expr ${event_num} % 2` == 0 ]; then
    echo "イベント${event_num} ユーザ1 参加"
    time curl -X PUT ${HOST}/events/$(cat tmp/event${event_num})/entry -H "Authorization: Bearer $(cat tmp/token1)"
  fi
done

# グループ
echo -n "グループ1作成 ユーザ1参加 ID="
time curl -sS -X POST -H "Authorization: Bearer $(cat tmp/token1)" ${HOST}/groups \
                 -F "name=IS-07" -F "note=ITスペシャリスト学科 7期のグループ" \
                 -F "is_private=false" \
                 -F "user_ids[]=$(cat tmp/user2_id)" -F "user_ids[]=$(cat tmp/user3_id)" -F "user_ids[]=$(cat tmp/user4_id)" \
                 -F "image=@${PWD}/images/kong.png" \
| jq -r .id | tee tmp/group1

for user_num in $(seq 2 8)
do
  echo "グループ1 user${user_num}参加"
  time curl -sS -X POST ${HOST}/groups/$(cat tmp/group1)/join -H "Authorization: Bearer $(cat tmp/token${user_num})"
done

echo -n "非公開グループ2作成 ユーザ1参加 ID="
time curl -sS -X POST -H "Authorization: Bearer $(cat tmp/token1)" ${HOST}/groups \
                 -F "name=Nee-co" -F "note=Nee-co開発メンバ" \
                 -F "is_private=true" \
                 -F "user_ids[]=$(cat tmp/user5_id)" -F "user_ids[]=$(cat tmp/user6_id)" -F "user_ids[]=$(cat tmp/user7_id)" \
                 -F "image=@${PWD}/images/kong.gif" \
| jq -r .id | tee tmp/group2

for group_num in $(seq 3 20)
do
  echo -n "グループ${group_num}作成 ユーザ2参加 ID="
  time curl -sS -sS -X POST -H "Authorization: Bearer $(cat tmp/token2)" ${HOST}/groups \
                       -F "name=IS-$(printf %02d ${group_num})" -F "note=ITスペシャリスト学科 ${group_num}期のグループ" \
                       -F "is_private=false" \
                       -F "image=@${PWD}/images/kong2.png" \
  | jq -r .id | tee tmp/group${group_num}

  if [ `expr ${group_num} % 2` == 0 ]; then
    echo "グループ${group_num} ユーザ1 招待"
    time curl -sS -X PUT ${HOST}/groups/$(cat tmp/group${group_num})/invite -H "Authorization: Bearer $(cat tmp/token2)" -d "user_ids[]=$(cat tmp/user1_id)"
  fi
done

# Folder/File
echo -n "TOPフォルダ ID="
time curl -sS -X GET -H "Authorization: Bearer $(cat tmp/token1)" ${HOST}/folders | jq -r .folders[0].id | tee tmp/top_folder

for folder_num in $(seq 1 5)
do
  echo -n "テストフォルダ${folder_num} 作成 ID="
  time curl -sS -X POST -H "Authorization: Bearer $(cat tmp/token1)" ${HOST}/folders \
                       -d "name=テストフォルダ${folder_num}_$(uuidgen)" \
                       -d "parent_id=$(cat tmp/top_folder)" \
  | jq -r .id | tee tmp/folder${folder_num}
done

echo "適当にフォルダ階層作成"
folder_id=$(cat tmp/folder1)
for folder_num in $(seq 6 10)
do
  echo -n "テストフォルダ${folder_num} 作成"
  folder_id=`curl -sS -X POST -H "Authorization: Bearer $(cat tmp/token1)" ${HOST}/folders \
                       -d "name=テストフォルダ${folder_num}_$(uuidgen)" \
                       -d "parent_id=${folder_id}" \
  | jq -r .id`
  echo ${folder_id}
done

echo -n "フォルダ1 > ファイルアップロード アップロード ID="
time curl -sS -sS -X POST -H "Authorization: Bearer $(cat tmp/token1)" ${HOST}/files \
                     -F "file=@${PWD}/files/caja.zip" \
                     -F "parent_id=$(cat tmp/folder1)" \
    | jq -r .id

for file_name in dios.png neeco.png nee-co_architecture.pdf
do
  echo -n "${file_name} アップロード ID="
  time curl -sS -sS -X POST -H "Authorization: Bearer $(cat tmp/token1)" ${HOST}/files \
                       -F "file=@${PWD}/files/${file_name}" \
                       -F "parent_id=$(cat tmp/top_folder)" \
  | jq -r .id
done
