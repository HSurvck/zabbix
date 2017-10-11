#!/bin/bash

tar xfP /server/tools/zabbix3.0.9_yum.tar.gz

yum -y --nogpgcheck -C install httpd \
mysql-server \
php55w \
php55w-mysql \
php55w-common \
php55w-gd \
php55w-mbstring \
php55w-mcrypt \
php55w-devel \
php55w-xml \
php55w-bcmath

yum -y --nogpgcheck -C install zabbix-web \
zabbix-server-mysql \
zabbix-web-mysql \
zabbix-get \
zabbix-java-gateway \
wqy-microhei-fonts \
net-snmp \
net-snmp-utils


cp /usr/share/mysql/my-medium.cnf /etc/my.cnf

/etc/init.d/mysqld start && \
echo "/etc/init.d/mysqld start" >> /etc/rc.local

mysql -e "create database zabbix character set utf8 collate utf8_bin;"

mysql -e "grant all on zabbix.* to zabbix@'localhost' identified by 'zabbix';"

zcat /usr/share/doc/zabbix-server-mysql-3.0.9/create.sql.gz |\
mysql -uzabbix -pzabbix zabbix


egrep -n "^post_max_size|^max_execution_time|^max_input_time|^date.timezone" /etc/php.ini

sed -i.ori 's#max_execution_time = 30#max_execution_time = 300#;s#max_input_time = 60#max_input_time = 300#;s#post_max_size = 8M#post_max_size = 16M#;910a date.timezone = Asia/Shanghai' /etc/php.ini

sed -i.ori '115a DBPassword=zabbix' /etc/zabbix/zabbix_server.conf

cp -R /usr/share/zabbix/ /var/www/html/ && \
chmod -R 755 /etc/zabbix/web && \
chown -R apache.apache /etc/zabbix/web

echo "ServerName 127.0.0.1:80" >>/etc/httpd/conf/httpd.conf

/etc/init.d/httpd start && \
echo "/etc/init.d/httpd start" >> /etc/rc.local

/etc/init.d/zabbix-server start && \
echo "/etc/init.d/zabbix-server start" >> /etc/rc.local 


cp /usr/share/fonts/wqy-microhei/wqy-microhei.ttc /usr/share/fonts/dejavu/DejaVuSans.ttf

ansible-playbook zabbix-agent.yml
