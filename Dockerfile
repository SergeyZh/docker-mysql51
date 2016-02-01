FROM sergeyzh/centos6-epel

MAINTAINER Sergey Zhukov, sergey@jetbrains.com

ENV MYSQL_VER Percona-Server-5.6.27-rel75.0-Linux.x86_64.ssl101

RUN yum install -y libaio numactl

RUN wget https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-5.6.27-75.0/binary/tarball/${MYSQL_VER}.tar.gz && tar -xzf ${MYSQL_VER}.tar.gz && \
    mv ${MYSQL_VER} mysql && rm ${MYSQL_VER}.tar.gz

VOLUME "/mnt/mysql"

ENV MYSQL_DATA /mnt/mysql/data
ENV MYSQL_BASE /mysql

RUN sed -i "s|^basedir=|basedir=${MYSQL_BASE}|g" /mysql/support-files/mysql.server && sed -i "s|^datadir=|datadir=${MYSQL_DATA}|g" /mysql/support-files/mysql.server
RUN /usr/sbin/useradd mysql && chown -R mysql.mysql /mysql /mnt/mysql

ENV PATH $PATH:/mysql/bin

ADD entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

ADD run-services.sh /
RUN chmod +x /run-services.sh

CMD /run-services.sh

EXPOSE 3306

