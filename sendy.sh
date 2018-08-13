#!/bin/bash

apt-get update
apt-get install -y php-mcrypt php-mbstring php7.0-curl php7.0-xml php7.0-gd
phpenmod mcrypt
phpenmod mbstring
phpenmod curl
phpenmod xml
phpenmod xmlreader
phpenmod simplexml
phpenmod gd
service php7.0-fpm restart