#!/bin/bash

# Author : Hoa Chan
# Copyright (c) hoachan.com
# Install nginx

## Setting timezone JST
rm -f /etc/localtime
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

cpu_cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
server_ip=$(curl -s https://hocvps.com/scripts/ip/)

# Install EPEL + Remi Repo
yum -y install epel-release yum-utils
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# Install Nginx Repo
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

# Create directory
if [ -d "/home/hoachan" ]
then
	rm -rf "/home/hoachan"
fi
mkdir -p /home/hoachan/public_html/records

# Clear services
yum -y remove php* httpd* nginx
yum clean all
yum -y update
yum -y upgrade

# Install Nginx, PHP-FPM and modules

# Enable Remi Repo
yum-config-manager --enable remi

# Install nginx
yum -y install nginx

# Install php
yum -y install php72w install php72w-cli  php72w-fpm
yum -y install php72w-mysql  php72w-xml php72w-curl
yum -y install php72w-opcache php72w-pdo php72w-gd
yum -y install php72w-pecl-apcu php72w-mbstring php72w-imap
yum -y install php72w-common php72w-mcrypt

# Autostart
chkconfig --add nginx
chkconfig --levels 235 nginx on
chkconfig --add php-fpm
chkconfig --levels 235 php-fpm on

# Log nginx
mkdir -p /var/log/nginx
mkdir -p /var/lib/php/session
chown -R nginx:nginx /var/log/nginx
chown -R nginx:nginx /var/lib/php/session
chmod 777 /var/log/nginx
chmod 777 /var/lib/php/session

# Start services
service nginx start
service php-fpm start

# Nginx

cat > "/etc/nginx/nginx.conf" <<END

user  nginx;
worker_processes  $cpu_cores;
worker_rlimit_nofile 260000;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
	worker_connections  2048;
	accept_mutex off;
	accept_mutex_delay 200ms;
	use epoll;
	#multi_accept on;
}

http {
	include       /etc/nginx/mime.types;
	default_type  application/octet-stream;

	log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
	              '\$status \$body_bytes_sent "\$http_referer" '
	              '"\$http_user_agent" "\$http_x_forwarded_for"';
		      
	#Disable IFRAME
	add_header X-Frame-Options SAMEORIGIN;
	
	#Prevent Cross-site scripting (XSS) attacks
	add_header X-XSS-Protection "1; mode=block";
	
	#Prevent MIME-sniffing
	add_header X-Content-Type-Options nosniff;
	
	access_log  off;
	sendfile on;
	tcp_nopush on;
	tcp_nodelay off;
	types_hash_max_size 2048;
	server_tokens off;
	server_names_hash_bucket_size 128;
	client_max_body_size 0;
	client_body_buffer_size 256k;
	client_body_in_file_only off;
	client_body_timeout 60s;
	client_header_buffer_size 256k;
	client_header_timeout  20s;
	large_client_header_buffers 8 256k;
	keepalive_timeout 10;
	keepalive_disable msie6;
	reset_timedout_connection on;
	send_timeout 60s;

	gzip on;
	gzip_static on;
	gzip_disable "msie6";
	gzip_vary on;
	gzip_proxied any;
	gzip_comp_level 6;
	gzip_buffers 16 8k;
	gzip_http_version 1.1;
	gzip_types text/plain text/css application/json text/javascript application/javascript text/xml application/xml application/xml+rss;

	include /etc/nginx/conf.d/*.conf;
}
END

cat > "/usr/share/nginx/html/403.html" <<END
<html>
<head><title>403 Forbidden</title></head>
<body bgcolor="white">
<center><h1>403 Forbidden</h1></center>
<hr><center>hocvps-nginx</center>
</body>
</html>
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
END

cat > "/usr/share/nginx/html/404.html" <<END
<html>
<head><title>404 Not Found</title></head>
<body bgcolor="white">
<center><h1>404 Not Found</h1></center>
<hr><center>hocvps-nginx</center>
</body>
</html>
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
<!-- a padding to disable MSIE and Chrome friendly error page -->
END

rm -rf /etc/nginx/conf.d/*


#setting server name
for server_name in records.8ppy.life
do
mkdir -p /home/logs/$server_name
chmod 777 /home/logs/$server_name

mkdir -p /home/hoachan/public_html/records
mkdir -p /home/hoachan/public_html/trends

case "$server_name" in
   "records.8ppy.life") root_nginx="/home/hoachan/public_html/records"
   ;;
esac

cat > "/etc/nginx/conf.d/$server_name.conf" <<END
server {
	listen 80;
		
	# access_log off;
	access_log /home/logs/$server_name/access.log;
	# error_log off;
    error_log /home/logs/$server_name//error.log;

    root $root_nginx;
	index index.php index.html index.htm;
    	server_name $server_name;
 
    	location / {
		try_files \$uri \$uri/ /index.php?\$args;
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
	
	location /nginx_status {
  		stub_status on;
  		access_log   off;
		allow 127.0.0.1;
		allow $server_ip;
		deny all;
	}
	
	location /php_status {
		fastcgi_pass 127.0.0.1:9000;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
		include /etc/nginx/fastcgi_params;
		allow 127.0.0.1;
		allow $server_ip;
		deny all;
    	}
	
	# Disable .htaccess and other hidden files
	location ~ /\.(?!well-known).* {
		deny all;
		access_log off;
		log_not_found off;
	}
	
    location = /favicon.ico {
        log_not_found off;
        access_log off;
    }
	
	location = /robots.txt {
		allow all;
		log_not_found off;
		access_log off;
	}
}
END
done

service nginx restart