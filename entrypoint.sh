#!/bin/bash
set -e

if [[ ! -d /mnt/mysql/etc ]] ; then
    mkdir -p /mnt/mysql/etc ${MYSQL_DATA}
fi

if [ -z "$(ls -A ${MYSQL_DATA})" -a "${3%_safe}" = '/run-services.sh' ]; then
        if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
                echo >&2 'error: database is uninitialized and MYSQL_ROOT_PASSWORD not set'
                echo >&2 '  Did you forget to add -e MYSQL_ROOT_PASSWORD=... ?'
                exit 1
        fi

	cd ${MYSQL_BASE}
        scripts/mysql_install_db --user=mysql --datadir=${MYSQL_DATA}

        # These statements _must_ be on individual lines, and _must_ end with
        # semicolons (no line breaks or comments are permitted).
        # TODO proper SQL escaping on ALL the things D:
        TEMP_FILE='/tmp/mysql-first-time.sql'
        cat > "$TEMP_FILE" <<-EOSQL
                DELETE FROM mysql.user ;
                CREATE USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' ;
                GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION ;
                DROP DATABASE IF EXISTS test ;
EOSQL

        if [ "$MYSQL_DATABASE" ]; then
                echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE ;" >> "$TEMP_FILE"
        fi

        if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
                echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" >> "$TEMP_FILE"

                if [ "$MYSQL_DATABASE" ]; then
                        echo "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%' ;" >> "$TEMP_FILE"
                fi
        fi

        echo 'FLUSH PRIVILEGES ;' >> "$TEMP_FILE"

        set -- $1 $2 "$3 --init-file=$TEMP_FILE"
fi

chown -R mysql:mysql ${MYSQL_DATA}

exec "$@"
