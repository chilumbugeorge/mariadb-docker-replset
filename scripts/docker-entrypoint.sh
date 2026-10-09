#!/bin/bash
set -e

echo "=========================================="
echo " MariaDB starting ..."
echo "=========================================="

MYSQL_DATA_DIR="/data/mysql/data"
MYSQL_LOG_DIR="/data/mysql/logs"
MYSQL_BINLOG_DIR="/data/mysql/binlog"
MYSQL_RELAYLOG_DIR="/data/mysql/relaylog"
MYSQL_CONFIG_DIR="/data/mysql/config"

mkdir -p \
    "$MYSQL_DATA_DIR" \
    "$MYSQL_LOG_DIR" \
    "$MYSQL_BINLOG_DIR" \
    "$MYSQL_RELAYLOG_DIR" \
    /run/mysqld

chown -R mysql:mysql \
    "$MYSQL_DATA_DIR" \
    "$MYSQL_LOG_DIR" \
    "$MYSQL_BINLOG_DIR" \
    "$MYSQL_RELAYLOG_DIR" \
    /run/mysqld

if [ ! -d "$MYSQL_DATA_DIR/mysql" ]; then
    echo "MariaDB data directory is empty."
    echo "Initializing MariaDB..."

    mariadb-install-db \
        --user=mysql \
        --datadir="$MYSQL_DATA_DIR"

    echo "MariaDB initialization complete."
fi

echo "Starting MariaDB..."

exec mysqld \
    --defaults-extra-file=/data/mysql/config/my.cnf \
    --user=mysql 
