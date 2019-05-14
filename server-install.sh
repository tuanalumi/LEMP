#!/bin/bash
echo "Ubuntu Server 18.04 installation script for..."
echo "- Nginx"
echo "- Php7.3"
echo "- MySQL 5.7"
echo "- Git, Curl & Composer"
echo "- Node.JS, Gulp, Bower & Socket.io - optional"
read -p "Continue with installation? (y/n)" CONTINUE
if [ $CONTINUE = "y" ]; then
	sudo apt-get -y update
	sudo apt-get install -y zip unzip
	echo "Note: Script assumes you have a file named nginx-site in script directory to be copied to /etc/nginx/sites-available"
	read -p "Install Nginx? (y/n)" NGINX
	if [ $NGINX = "y" ]; then
		sudo apt-get install -y nginx
		sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
		echo "Moving default site file to /etc/nginx/sites-available/default.backup"

		read -p "Name of nginx site: " NGINX_SITE

		sudo cp nginx-site /etc/nginx/sites-available/$NGINX_SITE
		sudo sed -i -e "s/myapp/$NGINX_SITE/g" /etc/nginx/sites-available/$NGINX_SITE
		read -p "Would you like to modify the Nginx site file? (y/n)" MOD
		if [ $MOD = "y" ]; then
			sudo nano /etc/nginx/sites-available/$NGINX_SITE
		fi
		sudo rm -f /etc/nginx/sites-enabled/default
		sudo ln -s /etc/nginx/sites-available/$NGINX_SITE /etc/nginx/sites-enabled/$NGINX_SITE
		sudo nginx -t
		sudo systemctl reload nginx
		sudo systemctl restart nginx

		read -p "Install Certbot? (y/n)" CERTBOT
		if [ $CERTBOT = "y" ]; then
			sudo apt-get install -y certbot python-certbot-nginx
			sudo certbot --nginx
		fi

		read -p "Enable HTTP2? (y/n)" HTTP2
		if [ $HTTP2 = "y" ]; then
			sudo sed -i -e "s/listen 443/listen 443 http2/g" /etc/nginx/sites-available/$NGINX_SITE
		fi
	fi
	read -p "Install PHP7.3? (y/n)" PHP
	if [ $PHP = "y" ]; then
		sudo add-apt-repository ppa:ondrej/php
		sudo apt-get -y update
		sudo apt install -y php7.3-fpm php7.3-cli php7.3-mbstring php7.3-mysql php7.3-xml php7.3-curl

		echo 'Setting cgi.fix_pathinfo=1 to /etc/php/7.3/fpm/php.ini'
		sudo sed -e -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=1/g' /etc/php/7.3/fpm/php.ini

		read -p "Would you like to modify the FPM php.ini file? (y/n)" INI
		if [ $INI = "y" ]; then
			sudo nano /etc/php/7.3/fpm/php.ini
		fi

		read -p "Would you like to modify the FPM www.conf file? e.g. change listen to 127.0.0.1:9000 (y/n)" INI
		if [ $INI = "y" ]; then
			sudo nano /etc/php/7.3/fpm/pool.d/www.conf
		fi

		sudo systemctl restart php7.3-fpm
	fi
	read -p "Install MySQL? (y/n)" MYSQL
	if [ $MYSQL = "y" ]; then
		sudo apt install -y mysql-server mysql-client
		sudo mysql_secure_installation
	fi
	read -p "Install Curl, Git & Composer? (y/n)" CGC
	if [ $CGC = "y" ]; then
		sudo apt-get install -y curl git
		curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
	fi
	read -p "Install Node.js? (y/n)" NODE
	if [ $NODE = "y" ]; then
		echo "Please select a version of Node.js:"
		echo "1. Node.js v 10.x"
		echo "2. Node.js v 11.x"
		read -p "Which version would you like? (1/2)" NODEV
		if [ $NODEV = "1" ]; then
			curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
		else
			curl -sL https://deb.nodesource.com/setup_11.x | sudo -E bash -
		fi
		sudo apt-get install -y nodejs
		read -p "Install Socket.io, bower & gulp? (y/n)" SIO
		if [ $SIO = "y" ];then
			sudo npm install -g socket.io
			sudo npm install -g bower
			sudo npm install -g gulp-cli
		fi
	fi

	read -p "Setup UFW?" UFW
	if [ $UFW = "y" ]; then
		sudo ufw allow ssh
		sudo ufw allow http
		sudo ufw allow https
		sudo ufw enable
	fi

else
	exit
fi
