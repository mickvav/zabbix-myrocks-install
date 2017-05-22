#!/bin/bash
apt-get update
apt-get install git g++ cmake libbz2-dev libaio-dev bison zlib1g-dev libsnappy-dev build-essential vim cmake perl bison ncurses-dev libssl-dev libncurses5-dev libgflags-dev libreadline6-dev libncurses5-dev libssl-dev liblz4-dev gdb smartmontools

apt-get install dpkg-dev devscripts chrpath dh-apparmor dh-systemd dpatch libboost-dev libcrack2-dev libjemalloc-dev libreadline-gplv2-dev libsystemd-dev libxml2-dev unixodbc-dev
apt-get install  libjudy-dev libkrb5-dev libnuma-dev libpam0g-dev libpcre3-dev pkg-config

if [ ! -d mariadb-10.2 ]; then
  git clone https://github.com/MariaDB/server.git mariadb-10.2
  cd mariadb-10.2
  git checkout bb-10.2-mariarocks
  git submodule init
else
  cd mariadb-10.2
  git pull
fi
git submodule update
make clean
rm CMakeCache.txt
if [ "$SKIP_MARIADB_REBUILD" = "" ]; then
   ./debian/autobake-deb.sh
else
   echo "Mariadb rebuild skipped"
fi

cd ..

if [ "$SKIP_MARIADB_INSTALL" = "" ]; then
  dpkg -i mariadb-common*.deb
  wget http://releases.galeracluster.com/debian/pool/main/g/galera-3/galera-3_25.3.20-1jessie_amd64.deb
  dpkg -i galera-3*.deb
  apt-get install gawk libdbi-perl socat
  
  dpkg -i mysql-common*.deb  mariadb-server*.deb mariadb-plugin*.deb mariadb-client*.deb libm*.deb
else
  echo "Mariadb install skipped"
fi

cp zabbix.my.cnf /etc/mysql/conf.d/
systemctl enable mariadb
