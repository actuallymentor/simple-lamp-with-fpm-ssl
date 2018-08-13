#!/bin/bash

echo -e 'What is the FQDN of the first webpage?\n'
read fqdn

mainconfig="
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/$fqdn
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
    RewriteEngine on
    RewriteCond %{SERVER_NAME} =$fqdn
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>

<IfModule mod_ssl.c>
    <VirtualHost *:443>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/$fqdn
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
        ServerName $fqdn
        SSLCertificateFile /etc/letsencrypt/live/$fqdn/fullchain.pem
        SSLCertificateKeyFile /etc/letsencrypt/live/$fqdn/privkey.pem
        Include /etc/letsencrypt/options-ssl-apache.conf
        <FilesMatch \.php$>
            SetHandler "proxy:unix:/var/run/php/php7.0-fpm.sock\|fcgi://localhost/"
        </FilesMatch>
    </VirtualHost>
</IfModule>
"

## Do the actual setup ##
apt update

apt install -y apache2 ufw mariadb-server php-fpm php libapache2-mod-fastcgi php-mysql libapache2-mod-php unattended-upgrades

# Enable modules
a2enmod proxy proxy_fcgi

# Configuration
echo "
ServerName $fqdn
" >> /etc/apache2/apache2.conf
echo "$mainconfig" > "/etc/apache2/sites-available/$fqdn.conf"
/bin/rm -f /etc/apache2/sites-enabled/*
ln -s "/etc/apache2/sites-available/$fqdn.conf" "/etc/apache2/sites-enabled/$fqdn.conf"


echo -e "Testing apache config status after install:\n"
apache2ctl configtest
echo -e '\nPress enter to continue...'
read

service apache2 restart

## Postinstalls ##
echo '<IfModule mod_dir.c>
    DirectoryIndex index.php index.html
</IfModule>' > /etc/apache2/mods-enabled/dir.conf


echo "<?php phpinfo(); ?>" > /var/www/html/info.php

## Security ##
echo -e "\ncgi.fix_pathinfo=0" >> /etc/php/7.0/fpm/php.ini
dpkg-reconfigure --priority=low unattended-upgrades
mysql_secure_installation


## Restarts ##
service php7.0-fpm restart
service mysql restart
service apache2 restart


## Firewall ##
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow in "Apache Full"
ufw disable
ufw enable

apt -y upgrade