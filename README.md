# LAPM ( Linux, Apache, MariaDB, PHP7 ) setup script

This is a setup script I'm using to set up a basic webserver that will run a sendy.co installation.

## lamp.sh

- Installs NginX
    + Install global config with gzip and caching
    + Install a default server with phpinfo to webroot
    + Password protect direct ip access
- Installs MariaDB
    + Run mysql_secure_installation after installation
- Installs PHP7
- Sets up automatic security updates
- Enable firewall
    + Deny all incoming
    + Allow SSH, HTTP, HTTPS

## enable-ssl.sh
- Install certbot
- Get ssl for domain

## sendy.sh

- Install php-modules needed for sendy
    + mcrypt
    + mbstring
    + curl
    + xml
    + xmlreader
    + simplexml
    + gd

## swapfile.sh

- Generate and enable swapfile
- Set swappiness to 10 out of 100
- Set vfs cache pressure to 50 out of 100