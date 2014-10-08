#!/bin/sh

shutdown(){
    kill `cat ${MYSQL_BASE}/mysql.pid`
    while [[ -f ${MYSQL_BASE}/mysql.pid ]]
    do
	PROGRESS="-"${PROGRESS}
	echo ${PROGRESS}
	sleep 1
    done
    killall tail
    exit 0
}

trap shutdown SIGINT SIGTERM SIGHUP

if [[ ! -f /mnt/mysql/etc/my.cnf ]] ; then
    cp /mysql/support-files/my-small.cnf /mnt/mysql/etc/my.cnf
fi

mysqld --defaults-file=/mnt/mysql/etc/my.cnf --basedir=${MYSQL_BASE} --datadir=${MYSQL_DATA} \
       --user=mysql --pid_file=${MYSQL_BASE}/mysql.pid $1 > /var/log/container.log 2>&1 &

touch /var/log/container.log
tail -F /var/log/container.log &

wait

