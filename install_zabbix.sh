#!/bin/bash
zabbixversion="3.2.5"
apt-get install libsnmp-dev libcurl4-openssl-dev python-requests
if [ ! -f zabbix-${zabbixversion}.tar.gz ]; then 
  wget https://downloads.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/${zabbixversion}/zabbix-${zabbixversion}.tar.gz
  tar -xvzf zabbix-${zabbixversion}.tar.gz
fi
cd zabbix-${zabbixversion}
groupadd zabbix
useradd -g zabbix zabbix
sed -i 's/mariadbclient/mariadb/' configure
./configure --enable-proxy --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2
make -j5
make install
cp ../zabbix_server.conf /usr/local/etc/zabbix_server.conf

mkdir /var/www/zabbix ; cp -r zabbix-3.2.5/frontends/php/* /var/www/zabbix

cd ..
git clone https://github.com/giapnguyen/snmpbuilder
cp -r snmpbuilder/snmp_builder* /var/www/html/zabbix/
