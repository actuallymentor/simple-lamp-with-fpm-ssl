# LEMP ( Linux, NginX, MariaDB, PHP7 ) setup script

This is a setup script I'm using to set up a basic webserver that will run a sendy.co installation.

## lemp.sh

- Installs NginX
    + Install global config with gzip and caching
    + Install a default server with phpinfo
    + Password protect direct ip access
- Installs MariaDB
    + Rund mysql_secure_installation after installation
- Installs PHp7
- Sets up automatric security updates
- Enable firewall
    + Deny all incoming
    + Allow SSh, HTTP, HTTPS

## sendy-adminer.sh

- Install php-modules needed for adminer and sendy
    + mcrypt
    + mbstring
    + curl
    + xml
    + xmlreader
    + simplexml
    + gd
- Download adminer to default server root (//server_ip/adminer)

## swapfile.sh

- Generate and enable swapfile
- Set swappiness to 10 out of 100
- Set vfs cache pressure to 50 out of 100
