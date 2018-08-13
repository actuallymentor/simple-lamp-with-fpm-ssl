echo "For what domain name is the SSL?"
read domain
yes | add-apt-repository ppa:certbot/certbot
apt update
apt install python-certbot-apache -y
certbot -d $domain
certbot renew --dry-run