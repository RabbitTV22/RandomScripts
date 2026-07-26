#!/bin/bash

# This script will install and configure nginx
# Made by Alec Lachance Lapalme
# 03/07/2026


# check if nginx is installed and if not, install it
if [[ $(rpm -q nginx 2> /dev/null) =~ .*not.* ]]; then
	echo "Installing nginx"
        sudo dnf install -y nginx
else 
	echo "Nginx already installed"
fi

#############
# Variables #
#############

SERVER_SUBNET="172.16.30.0/24"
SERVER_ALIAS_SUBNET="172.16.32.0/24"
CLIENT_SUBNET="172.16.31.0/24"
SERVER_IP="172.16.30.12"
CLIENT_IP="172.16.31.12"

if [ -f "/etc/nginx/nginx.conf.bak" ]; then 
	echo There is already a backup.
else
	cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
fi

if grep -q '^[[:space:]]*server[[:space:]]*{' /etc/nginx/nginx.conf; then
    start=$(sed -n '/^[[:space:]]*server[[:space:]]*{/{=;q;}' /etc/nginx/nginx.conf)
    end=$(sed -n '/^# Settings for a TLS enabled server/{=;q;}' /etc/nginx/nginx.conf)
    sudo sed -i "$start,$((end-1))d" /etc/nginx/nginx.conf
	echo Removed default server block
else
    echo Default server block already removed.
fi


CREATE_SERVER="Y"
echo We need to ask you a few more questions to create the web server.
echo
while [[ $CREATE_SERVER == "Y" ]]; do
	read -p "Do you want to make it with HTTPS? [Y/N]: " CREATE_SSL
	read -p "What port/bind ip do you want to use? " PORT
	read -p "What website hostname do you want to use? " HOSTNAME
	read -p "What directory do you want to use as the webroot? It will create a html folder in the directory you chose. " WEBROOT
	
	echo "Do you want to change the access or error log directory?"
	read -p "It is currently set to $WEBROOT/logs. Type the new log directory or type N: " LOG_DIR
	if [[ "$LOG_DIR" == "N" ]]; then
		LOG_DIR="$WEBROOT/logs"
		mkdir -p $LOG_DIR
		touch $LOG_DIR/{error,access}.log
	fi

	mkdir -p "$WEBROOT/html"
	cat > $WEBROOT/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>$HOSTNAME</title>
</head>
<body>
    <h1>Nginx Web Server</h1>
	<h1>$HOSTNAME MN: 12</h1>
</body>
</html>
EOF

	if [[ $CREATE_SSL == "Y" ]]; then
		PORT="$PORT ssl"
		mkdir -p /etc/nginx/tls/{key,cert} 2> /dev/null
		clear
		echo Creating Self Signed Certificate...
		echo
		openssl req -x509 -newkey rsa -days 120 -nodes -keyout /etc/nginx/tls/key/$HOSTNAME.key -out /etc/nginx/tls/cert/$HOSTNAME.cert
		SSL_CERT="ssl_certificate /etc/nginx/tls/cert/$HOSTNAME.cert;"
		SSL_KEY="ssl_certificate_key /etc/nginx/tls/key/$HOSTNAME.key;"
	fi

	read -p "Do you want to create another web server? [Y/N]: " CREATE_SERVER

	cat > /etc/nginx/conf.d/$HOSTNAME.conf <<EOF
server {
        listen       $PORT;
        server_name  $HOSTNAME;
        root         $WEBROOT/html;

        index index.html;

        $SSL_CERT
        $SSL_KEY

        location / {
        }

        error_log $LOG_DIR/error.log;
        access_log $LOG_DIR/access.log;
}
EOF

done

echo Nginx configured succesfully.

systemctl enable --now nginx
systemctl restart nginx
echo Nginx service restarted.
