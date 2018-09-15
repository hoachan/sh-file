#!/bin/bash

# Author : Hoa Chan
# Copyright (c) hoachan.com

# Install git
yum -y install git

#Install node
yum install -y nodejs

# Install composer
cd ~
curl -sS https://getcomposer.org/installer | sudo php
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