#!/bin/bash
sudo yum update all -y
sudo yum install -y httpd
sudo amazon-linux-extras install php7.4

sudo systemctl restart httpd.service
sudo systemctl enable httpd.service
wget https://wordpress.org/latest.zip
sudo unzip latest.zip
cp -a wordpress/* /var/www/html/
sudo cp -a wordpress/* /var/www/html/
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i 's/database_name_here/${DB_NAME}/g' /var/www/html/wp-config.php
sed -i 's/username_here/${DB_USER}/g' /var/www/html/wp-config.php
sed -i 's/password_here/${DB_PASSWD}/g' /var/www/html/wp-config.php
sed -i 's/localhost/${DB_HOST}/g' /var/www/html/wp-config.php
sudo chown -R apache.apache /var/www/html/*
sudo systemctl restart httpd.service
