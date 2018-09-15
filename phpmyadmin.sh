#!/bin/bash

# Author : Hoa Chan
# Copyright (c) hoachan.com
# Install mysql and phpmyadmin

#Instal phpmyadmin
phpmyadmin_version="4.8.0.1"
phpmyadmin_server_name="pma.vagrant.site"
admin_password=admin

# Create directory
if [ -d "/home/hoachan/phpmyadmin" ]
then
	rm -rf "/home/hoachan/phpmyadmin"
fi
mkdir /home/hoachan/phpmyadmin/

#Install
cd /home/hoachan/phpmyadmin/
wget -q https://files.phpmyadmin.net/phpMyAdmin/$phpmyadmin_version/phpMyAdmin-$phpmyadmin_version-english.zip
unzip -q phpMyAdmin-$phpmyadmin_version-english.zip
mv -f phpMyAdmin-$phpmyadmin_version-english/* .
rm -rf phpMyAdmin-$phpmyadmin_version-english*

#Create folder logs
mkdir /home/logs/$phpmyadmin_server_name
touch /home/logs/$phpmyadmin_server_name/access.log

cat > "/etc/nginx/conf.d/$phpmyadmin_server_name.conf" <<END
server {
	listen 80;

	# access_log off;
	access_log /home/logs/$phpmyadmin_server_name/access.log;
	# error_log off;
        error_log /home/logs/$phpmyadmin_server_name/error.log;

        root /home/hoachan/phpmyadmin;
	index index.php index.html index.htm;
    	server_name $phpmyadmin_server_name;

    	#auth_basic "Restricted";
	#auth_basic_user_file /home/hoachan/.htpasswd;

	location / {
		autoindex on;
		try_files \$uri \$uri/ /index.php;
	}

    	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
        	include /etc/nginx/fastcgi_params;
        	fastcgi_pass 127.0.0.1:9000;
        	fastcgi_index index.php;
		fastcgi_connect_timeout 1000;
		fastcgi_send_timeout 1000;
		fastcgi_read_timeout 1000;
		fastcgi_buffer_size 256k;
		fastcgi_buffers 4 256k;
		fastcgi_busy_buffers_size 256k;
		fastcgi_temp_file_write_size 256k;
		fastcgi_intercept_errors on;
        	fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    	}

	location ~ /\. {
		deny all;
	}

}
END

cp /home/hoachan/phpmyadmin/config.sample.inc.php /home/hoachan/phpmyadmin/config.inc.php
cat /home/hoachan/phpmyadmin/config.inc.php | sed "s/localhost/$db_host/g"

#restart
service nginx restart
