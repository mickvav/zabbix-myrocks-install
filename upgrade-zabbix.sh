#!/bin/bash

if [ "$SKIP_SCP" = "" ]; then
  echo "Backing up schemas:"
  ssh 194.152.34.43 "cd sbin/zabbix; ./backup.config.sh"
  scp 194.152.34.43:/root/sbin/zabbix/zabbix-*.sql .
fi
mysqluser=`cat /etc/mysql/debian.cnf|grep '^user' | head -n 1| awk '{print $3;};'`
mysqlpassword=`cat /etc/mysql/debian.cnf|grep '^password' | head -n 1| awk '{print $3;};'`

if [ "$SKIP_DROP_DB" = "" ]; then
  echo "drop db:"
  echo "DROP DATABASE zabbix;" | mysql -u$mysqluser -p$mysqlpassword
fi

echo "CREATE DATABASE zabbix;" | mysql -u$mysqluser -p$mysqlpassword
echo "load schemas:"
cat zabbix-0-schema.sql | mysql -u$mysqluser -p$mysqlpassword
cat zabbix-1-config.sql | mysql -u$mysqluser -p$mysqlpassword

tables=`echo "show tables" | mysql -u$mysqluser -p$mysqlpassword zabbix`;
for i in $tables; do
  echo "Droping partition on table $i"
  echo "ALTER TABLE $i REMOVE PARTITIONING" | mysql -u$mysqluser -p$mysqlpassword zabbix
done
cd zabbix_dbpatches_mysql/2.0
./upgrade -u$mysqluser -p$mysqlpassword zabbix
cd ../..
#wget http://repo.zabbix.com/zabbix/3.2/debian/pool/main/z/zabbix-release/zabbix-release_3.2-1+jessie_all.deb
#dpkg -i zabbix-release_3.2-1+jessie_all.deb
#apt-get update

. zabbix_server.conf
echo "GRANT ALL PRIVILEGES ON zabbix.* to $DBUser@localhost identified by '$DBPassword'" | mysql -u$mysqluser -p$mysqlpassword

echo 'delete from images where imageid in (select M from (select max(imageid) M,count(*) as N from images group by name having  N>1) T1)' | mysql -u$mysqluser -p$mysqlpassword zabbix
echo 'delete from images where imageid in (select M from (select max(imageid) M,count(*) as N from images group by name having  N>1) T1)' | mysql -u$mysqluser -p$mysqlpassword zabbix

echo 'alter table history_log add key `history_log_2` (`id`,`clock`)' | mysql -u$mysqluser -p$mysqlpassword zabbix
echo 'alter table history_text add key `history_text_2` (`id`,`clock`)' |  mysql -u$mysqluser -p$mysqlpassword zabbix
#echo 'alter table history_u add key `history_text_2` (`id`,`clock`)' |  mysql -u$mysqluser -p$mysqlpassword zabbix
#echo 'alter table history_text add key `history_text_2` (`id`,`clock`)' |  mysql -u$mysqluser -p$mysqlpassword zabbix
