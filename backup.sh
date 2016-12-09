#!/bin/sh
mkdir -p /tmp/backup/
mysql --host=$BACKUP_HOST --user=$BACKUP_USER --password=$BACKUP_PASSWORD --silent --execute "SHOW DATABASES" | while read DATABASE_NAME; do
  mkdir /tmp/backup/$DATABASE_NAME
  mysql --host=$BACKUP_HOST --user=$BACKUP_USER --password=$BACKUP_PASSWORD --silent --execute "SHOW TABLES FROM \`$DATABASE_NAME\`" | while read TABLE_NAME; do
    mysqldump --host=$BACKUP_HOST --user=$BACKUP_USER --password=$BACKUP_PASSWORD --complete-insert --single-transaction $DATABASE_NAME $TABLE_NAME > /tmp/backup/$DATABASE_NAME/$TABLE_NAME.sql
  done
done
rsync -a --delete /tmp/backup/ /mnt/gluster/mariadb/`date +%m-%d-%Y`/
CUTOFF=$((`date +%s`-2592000))
find /mnt/gluster/mariadb/ -mindepth 1 -maxdepth 1 -print | while read BACKUP; do
  DATE=`echo $BACKUP | cut -d "/" -f 5`
  CORRECT=`echo $DATE | cut -d "-" -f 3`-`echo $DATE | cut -d "-" -f 1`-`echo $DATE | cut -d "-" -f 2`
  BACKUPDATE=`date +%s -d $CORRECT`
  if [ $BACKUPDATE -lt $CUTOFF ]
  then
    rm -rf $BACKUP
  fi
done
