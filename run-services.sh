#!/bin/sh

trap "killall mysqld ; killall tail; exit 0" SIGINT SIGTERM SIGHUP

if [[ ! -f /mnt/mysql/etc/my.cnf ]] ; then
    cp /mysql/support-files/my-small.cnf /mnt/mysql/etc/my.cnf
fi

mysqld --defaults-file=/mnt/mysql/etc/my.cnf --basedir=${MYSQL_BASE} --datadir=${MYSQL_DATA}  --user=mysql $1 &

touch /var/log/container.log
tail -F /var/log/container.log &

wait

