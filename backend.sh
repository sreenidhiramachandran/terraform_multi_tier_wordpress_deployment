#!/bin/bash
sudo yum update all -y
sudo yum install mariadb-server -y
sudo systemctl restart mariadb.service
sudo systemctl enable mariadb.service
mysql -u root <<EOF
UPDATE mysql.user SET Password=PASSWORD('${MYSQL_PASSWD}') WHERE User='root';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.db WHERE Db='test' OR Db='test_%';
FLUSH PRIVILEGES;
EOF

mysql -e  "CREATE DATABASE ${DB_NAME}" -u root -p${MYSQL_PASSWD}
mysql -e  "CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWD}'" -u root -p${MYSQL_PASSWD}
mysql -e  "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%'" -u root -p${MYSQL_PASSWD}
mysql -e  "FLUSH PRIVILEGES" -u root -p${MYSQL_PASSWD}
sudo systemctl restart mariadb.service
