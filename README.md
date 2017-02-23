# vagrant-conoha

[![Gem Version](https://badge.fury.io/rb/vagrant-conoha.svg)](http://badge.fury.io/rb/vagrant-conoha)
[![Dependency Status](https://gemnasium.com/hironobu-s/vagrant-conoha.svg)](https://gemnasium.com/hironobu-s/vagrant-conoha)
[![Build Status](https://travis-ci.org/hironobu-s/vagrant-conoha.svg)](https://travis-ci.org/hironobu-s/vagrant-conoha)

[Vagrant](Vagrant ConoHa Provider)1.2以降で使える、[ConoHa](https://www.conoha.jp/)用のProviderです。

VagrantからConoHaにup, destroyやsshなどのコマンドを使用したり、サーバーのプロビジョニングが行えるようになります。

**Note:** このProviderは[ggiamarchi/vagrant-openstack-provider](https://github.com/ggiamarchi/vagrant-openstack-provider)をforkして作成されています。

## 機能

* VPSの作成、起動、停止、破棄が行えます
* ConoHaの各リージョンをサポートしています
* VPS作成時にプランとインストールイメージを選択できます
* SSHキーペアの自動作成、それを使ったSSH接続が行えます
* コントロールパネルから登録済みのSSHキーペアを使うこともできます。
* インストールイメージ一覧、VPSプランの一覧、ネットワーク、サブネットの一覧を取得するコマンドが用意されています
* その他Vagrantの各コマンドが使用できます(provisionなど)

## クイックスタート

あらかじめVagrant1.2以降をインストールしておきます。次に以下のコマンドでプラグインをインストールします。

```console
$ vagrant plugin install vagrant-conoha
```

次に以下の内容でVagrantfileを作成します。各パラメータの解説は[こちら](https://github.com/hironobu-s/vagrant-conoha/blob/master/source/Vagrantfile)

```VAGRANTFILE
ruby_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box       = 'conoha'
  config.ssh.username = 'root'
  config.ssh.pty      = true

  config.vm.provider :conoha do |conoha|
    conoha.openstack_auth_url = 'https://identity.tyo1.conoha.io/v2.0'

    conoha.username           = 'gncu*******'
    conoha.password           = '***********'
    conoha.tenant_name        = 'gnct*******'

    conoha.flavor             = 'g-1gb'
    conoha.image              = 'vmi-ubuntu-14.04-amd64'
    conoha.region             = "tyo1"
    conoha.admin_pass         = "AdminPass123*"
    conoha.metadata           = {
      instance_name_tag: "vagrant_conoha"
    }
    conoha.security_groups    = [
      "default",
      "gncs-ipv4-all",
      "gncs-ipv6-all"
    ]
    # conoha.keypair_name       = "hironobu-key"

  end
  # config.ssh.private_key_path = "~/.ssh/id_rsa"
end

```

そしてお待ちかねvagrant upを実行します。

```console
$ vagrant up --provider=conoha
```

## 詳細

下記URLをご覧下さい。
[VagrantからConoHaを使う - Qiita](http://qiita.com/hironobu_s/items/8422a427fd5571747196)

## サポート

このプラグインは非公式ですので、ConoHaのサポートなどへの問い合わせはご遠慮ください。
issueとかでお気軽にどうぞ。

## ライセンス

オリジナルに準じてMIT Licenseを適用します。
