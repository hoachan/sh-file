#!/bin/bash

# Author : Hoa Chan
# Copyright (c) hoachan.com
# Install mysql redis

# Preparing
yum -y install epel-release
yum -y remove mysql* redis


#install Redis ---> redis-server --version for confirm
yum install -y redis
systemctl start redis
systemctl enable redis

#install mysql
wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rpm -ivh mysql-community-release-el7-5.noarch.rpm
yum update
yum -y install mysql-server

systemctl start mysqld

#root --- root
chkconfig --add mysqld
chkconfig --levels 235 mysqld on

chkconfig --add redis
chkconfig --levels 235 redis on