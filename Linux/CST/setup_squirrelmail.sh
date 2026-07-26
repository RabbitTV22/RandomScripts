#!/bin/bash

# This script will install and configure squirrelmail
# Made by Alec Lachance Lapalme
# 03/07/2026


# check if requirements is installed and if not, install it
if [[ $(rpm -q dovecot 2> /dev/null) =~ .*not.* ]]; then
        echo "Installing requirements"
        sudo dnf install -y dovecot php php-fpm
else 
        echo "Requirements already installed"
fi

#############
# Variables #
#############

SERVER_SUBNET="172.16.30.0/24"
SERVER_ALIAS_SUBNET="172.16.32.0/24"
CLIENT_SUBNET="172.16.31.0/24"
CONFIG_FILE="/etc/postfix/main.cf"
DOMAIN="blue.lab"

ALIAS_USER="labfinal"
ALIAS_TO="foo"


read -p "Do you want the script to do the configuration for docevot?: " DO_CONFIG

if [[ $DO_CONFIG =~ ^[Yy]$ ]]; then
        sed -i "s/#protocols = imap pop3 lmtp submission/protocols = imap pop3 lmtp submission/" /etc/dovecot/dovecot.conf
        sed -i "s|#   mail_location = maildir:~/Maildir|mail_location = maildir:~/Maildir|" /etc/dovecot/conf.d/10-mail.conf
        sed -i "s/#disable_plaintext_auth = yes/disable_plaintext_auth = yes/" /etc/dovecot/conf.d/10-auth.conf
        sed -i "s/auth_mechanisms = plain/auth_mechanisms = plain login/" /etc/dovecot/conf.d/10-auth.conf
        sed -i "s/auth_mechanisms = plain/auth_mechanisms = plain login/" /etc/dovecot/conf.d/10-auth.conf
        sed -i '102c\    user = postfix' /etc/dovecot/conf.d/10-master.conf
        sed -i '103c\    group = postfix' /etc/dovecot/conf.d/10-master.conf
        sed -i "s/ssl = required/ssl = no/" /etc/dovecot/conf.d/10-ssl.conf
	echo Dovecot configured succesfully.

fi

systemctl enable --now dovecot
systemctl restart dovecot
echo Dovecot service restarted.

cd /var/www/

wget https://rabbit-network.net/assets/squirrelmail-webmail-1.4.22.tar.gz
tar xzf squirrelmail-webmail-1.4.22.tar.gz
mv squirrelmail-webmail-1.4.22 webmail
cd webmail
mkdir logs
cd config
echo "1, 1, \"Alec Mail Server\", S, R, 2, 1, blue.lab, S, 3, 2, S, Q"
./conf.pl
sed -i "s|\$data_dir[[:space:]]*=.*;|\$data_dir                 = '/var/www/webmail/data/';|" /var/www/webmail/config/config.php
chown -R apache:apache /var/www/webmail/data
chmod -R 750 /var/www/webmail/data
echo "server {
        listen       80;
        server_name  webmail.$DOMAIN;
        root         /var/www/webmail;

        index index.php;

        error_log /var/www/webmail/logs/error.log;
        access_log /var/www/webmail/logs/access.log;

        location / {
                try_files \$uri \$uri/ /index.php?\$args;
        }

        location ~ \.php$ {
                fastcgi_pass unix:/run/php-fpm/www.sock;
                fastcgi_index index.php;
                fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                include fastcgi_params;
        }

        location ~ /\.ht {
                deny all;
        }
}
" > /etc/nginx/conf.d/webmail.conf

systemctl restart nginx