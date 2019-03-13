#!/bin/bash

apt-get -y update
apt-get -y install nginx

sudo rm -f /var/www/html/*
sudo wget https://raw.githubusercontent.com/gcastill0/hc-stack/master/azure/web/index.nginx-debian.html -P /var/www/html
sudo wget https://raw.githubusercontent.com/gcastill0/hc-stack/master/azure/web/chaos.js -P /var/www/html
sudo wget https://raw.githubusercontent.com/gcastill0/hc-stack/master/azure/web/lorenz1.js -P /var/www/html
