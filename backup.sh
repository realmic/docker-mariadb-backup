#!/bin/sh
mkdir -p /tmp/backup/
mysql --host=$BACKUP_HOST --user=$BACKUP_USER --password=$BACKUP_PASSWORD --silent --execute "SHOW DATABASES" | while read DATABASE_NAME; do
  mkdir /tmp/backup/$DATABASE_NAME
  mysql --host=$BACKUP_HOST --user=$BACKUP_USER --password=$BACKUP_PASSWORD --silent --execute "SHOW TABLES FROM \`$DATABASE_NAME\`" | while read TABLE_NAME; do
    mysqldump --host=$BACKUP_HOST --user=$BACKUP_USER --password=$BACKUP_PASSWORD --complete-insert --single-transaction $DATABASE_NAME $TABLE_NAME > /tmp/backup/$DATABASE_NAME/$TABLE_NAME.sql
  done
done
rsync -a --delete /tmp/backup/ /mnt/gluster/mariadb/`date +%m-%d-%Y`/
find /mnt/gluster/mariadb/ -maxdepth 1 -daystart -mtime +30 -exec rm -rf {} +
