#!/bin/bash

sudo apt-get -y update
sudo apt-get -y install nginx
sudo rm -f /var/www/html/*
sudo wget https://raw.githubusercontent.com/gcastill0/hc-stack/master/web/index.nginx-debian.html -P /var/www/html
sudo wget https://raw.githubusercontent.com/gcastill0/hc-stack/master/web/chaos.js -P /var/www/html
sudo wget https://raw.githubusercontent.com/gcastill0/hc-stack/master/web/lorenz1.js -P /var/www/html
sudo systemctl restart nginx
