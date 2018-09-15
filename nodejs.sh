#!/bin/bash

# Author : Hoa Chan
# Copyright (c) hoachan.com
# Install nodejs

yum -y remove nodejs npm

yum install epel-release

yum install nodejs

yum install npm
