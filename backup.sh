#!/bin/bash

# Stop the script if a command fails
set -euo pipefail

#############
# Variables #
#############
dir_to_backup="/dir/to/backup"
backup_dir="/backup/dir/"
backup_name="backupName"

# Timestamp variable (year-month-day_hour-min-sec)
timestamp=$(date "+%Y-%m-%d_%H-%M-%S")

# Make sure root runs this script
if [[ "$EUID" -ne 0 ]]; then
    echo "You are not root. You must be root to run this script."
    exit 1
fi

# Log the script in a file
exec > "/var/log/$backup_name.log" 2>&1

# If script was ran with -i, initiate first run.
firstRun=0
while getopts i opt; do
    case "$opt" in
        i) firstRun=1 ;;
    esac
done

# Execute first run install
if [[ "$firstRun" -eq 1 ]]; then
    if command -v apt >/dev/null 2>&1; then
        if ! command -v rsync >/dev/null 2>&1; then
            apt install rsync -y
        fi
    elif command -v dnf >/dev/null 2>&1; then
        if ! command -v rsync >/dev/null 2>&1; then
            dnf install rsync -y
        fi
    elif command -v pacman >/dev/null 2>&1; then
        if ! command -v rsync >/dev/null 2>&1; then
            pacman -S --noconfirm rsync
        fi
    fi

    # Make sure the server-backup directory exists
    if [ ! -d "/etc/server-backup" ]; then
        mkdir -p /etc/server-backup/scripts
    fi
    # Make sure the backup directory exists
    if [ ! -d "$backup_dir" ]; then
        mkdir -p "$backup_dir"
    fi
    echo 5 > /etc/server-backup/backup-count.conf
fi

if [[ ! -d "$dir_to_backup" ]]; then
    echo "[$timestamp] $dir_to_backup does not exist." 
    exit 1
fi

# Move and compress the files
echo "[$timestamp] Copying and Archiving Backup..."
# Create folder to contain the files so they dont spill while decompressing
tar --transform "s|^|$backup_name=$timestamp/|" -czf "$backup_dir/$backup_name-$timestamp.tar.gz.tmp" -C "$dir_to_backup" .
# Move temp archive to final archive to make sure the compressing completes successfully
mv "$backup_dir/$backup_name-$timestamp.tar.gz.tmp" "$backup_dir/$backup_name-$timestamp.tar.gz"
echo "[$timestamp] Done copying and archiving"


# Add backup entry for this backup
echo "$backup_name-$timestamp" >> /etc/server-backup/$backup_name.txt

# Check to delete old backup
while [ $(wc -l < "/etc/server-backup/$backup_name.txt") -gt $(cat /etc/server-backup/backup-count.conf) ]; do
    echo "[$timestamp] Deleting old backup..."
    # Get the top line on the backup entries
    old_backup=$(head -1 /etc/server-backup/$backup_name.txt)
    # Copy everything but the top line to a temp file
    tail -n +2 /etc/server-backup/$backup_name.txt > /etc/server-backup/$backup_name.tmp
    # Override the backup entries with the temp file
    mv /etc/server-backup/$backup_name.tmp /etc/server-backup/$backup_name.txt
    # Delete the old archive
    rm -f "$backup_dir/$old_backup.tar.gz"
    echo "[$timestamp] Done deleting $old_backup"
done

echo "[$timestamp] Done backup"
