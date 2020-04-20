# WindowsでのLinux利用

WindowsでLinuxを利用するための方法を2つあげます。

利用しやすい方を使うか、双方を試してみてもよいでしょう。

WSLはLinuxの実行ファイルをWindows上でネイティブ実行するためのもの。
Windows上で実行されているためすべてのLinuxの機能が利用できるわけではないが特にSHELLコマンドを利用するなどでは充分すぎるほど。(dockerなどは利用不可)
Windows上のファイルへもそのままアクセスできる。

※ LinuxカーネルをまるごとOSに内蔵するWSL2が2004リリースで利用可能になる予定。

multipassはWindows/macOS/Linuxで使える仮想マシン管理ツール。

デフォルトでは、LinuxはQEMU, MacOSXではhyperkit, WindowsではHyper-Vを利用して仮想マシンを起動。(VirtualBox等も利用可能)
仮想マシンとしてLinux OSを起動するためより純粋なLinux環境。

multipassはHyper-V等で仮想マシンを作成してもよいが、作成や設定等を一発でやってくれるというもの。実体はHyper-Vの仮想マシンと考えていい。

## WSL - Windows subsystem for Linux

refs: https://docs.microsoft.com/ja-jp/windows/wsl/install-win10

### WSLの有効化

```
Open Powershell(管理者):
> Get-WindowsOptionalFeature -online -FeatureName Microsoft-Windows-Subsystem-Linux
   State: Disabled
> Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
> 再起動
```

### ストアアプリからインストール

ストアアプリから> WSLで検索> Ubuntu or Ubuntu 18.04 LTS > 入手

Use Across your devices> No, thanks (MicrosoftアカウントがあればSignしても可。どちらでも)

### 初期設定

スタートメニュー> Ubuntu or Ubuntu18.04

```
Installing, this may take a few minutes...
...
Enter new UNIX username:
Enter new UNIX password:
...
Installation successful!
```

## Windows multipass - Hyper-V

refs: https://multipass.run/docs

### Hyper-Vの有効化

インストール要件の確認

- Win+R: ms-settings:about
- エディション: Windows10 pro (HOME エディションでは利用不可)
- システムの種類: 64ビットであること

```
Win+R: powershell
> systeminfo.exe| Select-Object -Last 10
Hyper-V の要件: VM モニター モード拡張機能: はい
               ファームウェアで仮想化が有効になっています: はい
               第 2 レベルのアドレス変換: はい
               データ実行防止が使用できます: はい
```

すべて「はい」となっていること。Hyper-Vが既に有効な場合は「ハイパーバイザーが検出されました」と表示される。

「ファームウェアで仮想化が有効」になっていない場合は BIOS/UEFIから仮想化を有効化する。

```
BIOS設定から:
- Virtualization Technology(VT-x)
   → PCによって設定の場所や項目名も微妙に異なるのでそれらしいものを探す。
    CPUやAdvancedなどのセクションにある。
```

```
Win+R: powershell
> start-process powershell.exe -Verb runas
> Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
    State: Disabled
> Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    この操作を完了するために、今すぐコンピューターを再起動しますか?
    [Y] Yes  [N] No  [?] ヘルプ (既定値は "Y"): Y
スタートメニュー＞ Hyper-Vマネージャー
起動できることを確認し、終了。
```

### multipassのインストール

Windows 10 version 1803以上が必要。まずは最新にアップデート。

* インストーラーを取得してインストール
  - https://github.com/canonical/multipass/releases
    - 最新の「〜win64.exe」を探す↓
  - https://github.com/canonical/multipass/releases/download/v1.1.0/multipass-1.1.0+win-win64.exe
  - 保存> 実行でインストール
  - スタートメニュー> multipass

```
Win+R: powershell
> multipass version
> multipass find
> $vmname = "blue21"    # 適当なホスト名。省略するとランダムな名前がふられる。
> multipass launch --name $vmname
    (以下のメッセージでタイムアウトになるが処理は続行している)
    launch failed: The following errors occurred:
    timed out waiting for response
> multipass ls
    IPV4がUNKNOWNからIPアドレスに変更になるまで待つ。
> multipass info --all
> multipass exec $vmname -- ls -a
> multipass shell $vmname
  以降、Linux上での操作可能
  Ctrl+D
```
