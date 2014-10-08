docker-mysql51
==============

MySQL 5.1

Environment variables:
======================

* `MYSQL_ROOT_PASSWORD`
* `MYSQL_USER`
* `MYSQL_DATABASE`

Usage
=====

Mount external volume to `/mnt/mysql` with the following stricture:
```
/mnt/mysql/
       \__/data/ - MySQL data
       \__/etc/my.cnf - MySQL config
       \__/tmp/  - MySQL tmp folder (optional)
       
```

Fleet usage
===========

### mysql.service

```
[Unit]
Description=MySQL
After=mnt-data.mount
Requires=mnt-data.mount

[Service]
TimeoutStartSec=2400s
TimeoutStopSec=400s
ExecStartPre=/usr/bin/docker pull sergeyzh/mysql51

ExecStart=/usr/bin/docker run -e MYSQL_ROOT_PASSWORD=tmp_password -v /mnt/data:/mnt/mysql \
          -p 3306:3306 \
          --name mysql \
          sergeyzh/mysql51

ExecStop=-/usr/bin/docker stop -t 300 mysql
ExecStopPost=-/usr/bin/docker rm mysql
Restart=on-failure
```

### mnt-data.mount

```
[Unit]
DefaultDependencies=no
Conflicts=umount.target
Before=local-fs.target umount.target
ConditionVirtualization=!container

[Mount]
What=/dev/mapper/VG0-data
Where=/mnt/data
Options=
Type=ext4

```