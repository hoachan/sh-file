#!/bin/bash

# Author : Hoa Chan
# Copyright (c) hoachan.com
# Install mysql redis

#install Redis ---> redis-server --version for confirm
yum install -y redis
systemctl start redis

#install mysql
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
sudo rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum update

sudo yum install mysql-server
sudo systemctl start mysqld

#root --- root
chkconfig --add mysqld
chkconfig --levels 235 mysqld on

chkconfig --add redis
chkconfig --levels 235 redis on