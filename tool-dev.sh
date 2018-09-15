#!/bin/bash

# Author : Hoa Chan
# Copyright (c) hoachan.com

# sudo su
yum install wget

### 時刻同期
yum -y install ntpdate

### ntpdの代わり(Centos7から変更された)
yum -y install chrony

### テキストエディタ
yum -y install vim

### mailコマンド
yum -y install mailx

### zip解凍に使う
yum -y install unzip

### bashの補完機能強化
yum -y install bash-completion

### システム監査結果のログ保存を行う
systemctl disable auditd.service

### カーネルクラッシュのダンプ取得
systemctl disable kdump.service

#install to use ifconfig
yum install net-tools

# Install git
yum -y install git

#Install node
#yum install -y nodejs

# Install composer
cd ~
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
ln -s /usr/local/bin/composer /usr/bin/composer

# Swap
dd if=/dev/zero of=/swapfile bs=1024 count=4096k
mkswap /swapfile
swapon /swapfile
echo /swapfile none swap defaults 0 0 >> /etc/fstab
chown root:root /swapfile
chmod 0600 /swapfile
sysctl vm.swappiness=10
echo 'vm.swappiness = 10' >> /etc/sysctl.conf

clear
printf "Install success"