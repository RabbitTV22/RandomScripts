#!/bin/bash
set -euo pipefail

exec > /var/log/$backup_name.log 2>&1

date=$(date "+%Y-%m-%d_%H-%M-%S")
dir_to_backup="/dir/to/backup"
backup_dir="/backup/dir/"
backup_name="backupName"

if [ ! -d "/etc/server-backup" ]; then
    mkdir /etc/server-backup
fi

echo "[$date] Copying Server..."
rsync -a $dir_to_backup "$backup_dir/$backup_name-$date/" 
echo "[$date] Done copying"

echo "[$date] Archiving Server..."
cd "$backup_dir"
tar -czf "$backup_dir/$backup_name-$date.tar.gz" "$backup_name-$date"
echo "[$date] Done archiving"

echo "[$date] Deleting folder $backup_dir/$backup_name-$date"
rm -rf "$backup_dir/$backup_name-$date/"
echo "[$date] Done deleting"

echo "$backup_name-$date" >> /etc/server-backup/$backup_name.txt

if [ $(wc -l < /etc/server-backup/$backup_name.txt) -gt $(cat /etc/server-backup/backup-count.conf) ]; then
echo "[$date] Deleting old backup..."
old_backup=$(head -1 /etc/server-backup/$backup_name.txt)
tail -n +2 /etc/server-backup/$backup_name.txt > /etc/server-backup/$backup_name.tmp
mv /etc/server-backup/$backup_name.tmp /etc/server-backup/$backup_name.txt

rm -f "$backup_dir/$old_backup.tar.gz"
echo "[$date] Done backup"
fi
