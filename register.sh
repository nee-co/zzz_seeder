HOST=${HOST:="http://localhost:8001"}

api () {
  curl -s -XPOST --url "${HOST}/apis" --data "name=$1" --data "upstream_url=$2" --data "request_path=$3" -o : && echo -n $1
  curl -s -XPOST --url "${HOST}/apis/$1/plugins" --data "name=cors" -o : && echo -ne "\t cors"

  if [ "$4" = "jwt" ]; then
    curl -s -XPOST --url "${HOST}/apis/$1/plugins" --data "name=jwt" --data "config.claims_to_verify=exp" -o : && echo -ne "\t jwt"
  fi
  echo
}

# Aldea
api Aldea-Events        http://aldea-application:3000  /events        "jwt"

# Cadena
api Cadena-Groups       http://cadena-application:3000 /groups        "jwt"

# Caja
api Caja-Files          http://caja-application:9000   /files         "jwt"
api Caja-Folders        http://caja-application:9000   /folders       "jwt"
api Caja-Download       http://caja-application:9000   /download

# Cuenta
api Cuenta-LoginUser    http://cuenta-application:4000 /user          "jwt"
api Cuenta-Users        http://cuenta-application:4000 /users         "jwt"
api Cuenta-Token        http://cuenta-application:4000 /token
api Cuenta-TokenRefresh http://cuenta-application:4000 /token/refresh "jwt"
api Cuenta-TokenRevoke  http://cuenta-application:4000 /token/revoke  "jwt"

# Olvido
api Olvido-Questions    http://olvido-application:8080 /questions     "jwt"
