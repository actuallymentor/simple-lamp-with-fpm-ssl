#!/bin/bash

# Grab user input
echo -e "\nThis script installs a phpinfo and Adminer."
echo "These show system info and allow database access."
echo "For security purposes we will add a username and password."
echo -e "You will be asked for this password when visiting the server IP directly.\n"

echo -e "\nWhat username do you want to use to log into the default test server? [Enter when done]:"
read nguser

echo -e "\nWhat password do you want to use to log into the default test server? [Enter when done]:"
read ngpass

## Vars ##
workerprocesses=$(grep processor /proc/cpuinfo | wc -l)
workerconnections=$(ulimit -n)

## Configs ##
global_nginx_conf="
user  www-data www-data;
worker_processes  $workerprocesses;
events {
    worker_connections  $workerconnections;
}
http {

    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    server_tokens off;
    sendfile        on;

    # Gzip configuration
    include /etc/nginx/gzip.conf;

    # Add local servers
    include /etc/nginx/sites-enabled/*.conf;

    # Buffers
    client_body_buffer_size 10K;
    client_header_buffer_size 1k;
    client_max_body_size 8m;
    large_client_header_buffers 2 1k;

    # Timeouts
    client_body_timeout 12;
    client_header_timeout 12;
    keepalive_timeout 15;
    send_timeout 10;

    # Log off
    access_log off;
}
"
nginx_conf='
server {

    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/localhost;
    index index.html index.htm index.php;

    server_name localhost;
    client_max_body_size 32M;
    large_client_header_buffers 4 16k;

    include /etc/nginx/cache.conf;
    include /etc/nginx/gzip.conf;

    # Serving files
    location / {
        try_files $uri $uri/ /index.php;
        auth_basic "Restricted Content";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
    # Use php
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
    }

    error_page 401 403 404 /404.html;
    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
    }
}'

gzipconf='
gzip on;
gzip_disable "msie6";
gzip_vary on;
gzip_proxied any;
gzip_comp_level 6;
gzip_buffers 16 8k;
gzip_http_version 1.1;
gzip_min_length 256;
gzip_types text/plain text/css text/xml application/xml application/javascript application/x-javascript text/javascript application/vnd.ms-fontobject application/x-font-ttf font/opentype image/svg+xml image/x-icon;
'

cache='
location ~* .(jpg|jpeg|png|gif|ico|css|js)$ {
expires 365d;
}'

## Do the actual setup ##
apt-get update
apt-get -y upgrade

apt-get install -y nginx ufw mariadb-server php-fpm php-mysql unattended-upgrades

## Postinstalls ##
mkdir -p /var/www/localhost/
echo "$global_nginx_conf" > /etc/nginx/nginx.conf
echo "$nginx_conf" > /etc/nginx/sites-available/default.conf
echo "$cache" > /etc/nginx/cache.conf
echo "$gzip" > /etc/nginx/gzip.conf
echo "<?php phpinfo(); ?>" > /var/www/localhost/index.php

## Enable phpinfo page on IP ##
ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

## Security ##
echo -e "\ncgi.fix_pathinfo=0" >> /etc/php/7.0/fpm/php.ini
dpkg-reconfigure --priority=low unattended-upgrades
mysql_secure_installation

# Nginx password for direct ip access #
echo -n "$nguser:" >> /etc/nginx/.htpasswd
openssl passwd -apr1 $ngpass >> /etc/nginx/.htpasswd


## Restarts ##
service php7.0-fpm restart
service mysql restart
service nginx restart


## Firewall ##
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 'Nginx HTTP'
ufw allow 'Nginx HTTPS'
ufw disable
ufw enable