# Flutter×Laravel

## アプリ概要

モバイル

### 仕様

- モバイル

### 技術スタック

- Flutter3

## 環境構築

### 事前準備

flutter doctor により、ローカル環境で実行可能か確認する。
エラーが出ていた場合、ログに従い、修正等を行う。

### バックエンド起動確認

APIのdockerコンテナが起動していること。

### パッケージのインストール

```
cd /minmemo-mobile
flutter pub get
```

### エミュレーターの起動

上記コマンド実行後、エミュレーターを起動し、デバッグを開始する。

### エミュレーターの起動方法
- 「Ctrl」+「Shift」+「P」でコマンドパレットを開き、「Flutter: Launch Emulator」を選択し、任意のエミュレーターを起動する。
- 「Ctrl」+「Shift」+「P」でコマンドパレットを開き、「Flutter: Select Device」を選択し、先程起動したエミュレーターを選択する。
- 「F5」でデバッグ開始する。(※libディレクトリのdartファイル上で行う)
- アプリがエミュレーター上で起動していることを確認。
- 「Ctrl」+「Shift」+「P」でコマンドパレットを開き、「Dart: Open DevTools」を選択し、「Open DevTools in Web Browser」でデバックツールを起動する。
