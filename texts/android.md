# オススメIDE
+ AndroidStudio(EclipseはGoogleが終了宣言してるっぽい) 

設定とかは特にないけどエミュレーターはGenyMotionを使うと幸せになれる  
もっと速い奴あるよ！とかBlueStacksがあるからそっち使いたい…　とかあればそっち使うともっと幸せになれるかも  
(BlueStacksでデバックできるかは知らんけど…)

# AndroidProject作成時にできるフォルダ説明？
+ /java/<パッケージ名>   
	- みんな大好きjavaのソースファイルが詰まっている場所
+ /res/layout
	- プロジェクトのレイアウトファイルが詰まってる場所
+ /res/drawable-XXXX（多分プロジェクト生成時にはないため自分で作る可能性あり）
	- xhdpi 超高解像度画像（～３２０dpi）
	- hdpi 高解像度画像（～２４０dpi）
	- mdpi 中解像度画像（～１６０dpi）
	- ldpi 低解像度画像（～１２０dpi）
+ /res/values
	- 文字データやスタイル情報が詰まっている場所(主にStrings.xml重要)
+ /manifests
	- アプリ全体の設定ファイルが詰まっている場所

# サンプルコード　...の超大まかなな説明？
そのまえに…　Androidのソースを見て**混乱しないために理解しておく事**があります。  
それはAndroidアプリはイベントドリブンモデル(イベント駆動モデル)であるという事です。   
そのへんを説明するために引用 
> Androidでは、さまざまなイベントが存在します。  
  イベントとは「ボタンがクリックされた」、「別の画面に切り替えた」など、アプリ上で発生するできごとのことです。  
  そして、このように随所で発生したイベントに応じて実行すべきコードを記述するプログラミングモデルを  
  イベンドドリブンモデルと言います。  
  Androidアプリでは、ユーザーの操作やアプリの状態を監視し、それぞれのタイミングで行うべきコードを書いていくのが基本です。
  なお、イベントが発生したタイミングで実行すべきコード（メソッド）の事を"イベントハンドラー"といいます。

これを理解しておかないと、「このメソッドどこで呼んでるの？」とか混乱する事になります。  
さて、これを踏まえてコードを見ていきましょう。  

Activity（画面）を定義するファイル
~~~~
activity_main.xml

<RelativeLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools" 
    android:layout_width ="match_parent"
    android:layout_height ="match_parent">

    <TextView
        android:text="Hello World!"				//Hello World　をセット
        android:layout_width="wrap_content"		//幅を自動調節
        android:layout_height="wrap_content"    //高さを自動調節
        android:id="@+id/textView"/>			//idはそのViewをActivity内で一意に特定できる物を

</RelativeLayout>
~~~~

Activityの処理を書くクラス
~~~~
MainActivity

public class MainActivity extends Activity{
	@Override
	public void onCreate(Bundle saveInstanceState){   //Bundleはちゃんと開発するなら理解が必要だけど今は不要
		super.onCreate(saveInstanceState);            //Activityクラスを継承しているので、ここでコンストラクタを呼び出し
		setContentView(R.layout.activity_main);       //ここでレイアウトファイルと関連付け

		//適当に処理を書いていくjavaのmainメソッドみたいなもん
	}
}
~~~~

環境によって細部が少し変わると思うけど、だいたいこんな感じになると思う。  
onCreateOptionsMenuとか色々あるだろうけど、それがイベントハンドラーで、多分今は必要ない。  


#　使えるクラス
と言っても私自身あまり開発経験はないので何を挙げたら良いかわからない。  
最初歩の…触りだけで言えば

+ Intentクラス
+ ViewクラスのfindViewByIdメソッド

くらいだろうか？

# 多分良いサイト
[Androidアプリ開発入門](http://androidguide.nomaki.jp/)  
[ドットインストール](http://dotinstall.com/lessons/basic_android_v2)  
[ど素人のAndroidアプリ開発入門](http://androidhacker.blog94.fc2.com/)  

とかを参考にしてた。
