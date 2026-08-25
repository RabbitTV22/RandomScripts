```bash
wget https://raw.githubusercontent.com/RabbitTV22/RandomScripts/refs/heads/main/setup_purpur.sh
chmod +x setup_purpur.sh
./setup_purpur.sh
```


```bash
wget https://raw.githubusercontent.com/RabbitTV22/RandomScripts/refs/heads/main/debian_install.sh
chmod +x debian_install.sh
./debian_install.sh
```


# How to use the backup script

### Set the backup name, directory to backup, and backup directory inside the script
```sh
dir_to_backup="/dir/to/backup"
backup_dir="/backup/dir/"
backup_name="backupName"
```
### Run the script once with the -i flag to generate the files and directories
```sh
chmod u+x backup.sh
./backup.sh -i
```
### Set the number of backups it will create before it starts deleting the oldest backup
```sh
echo 5 > /etc/server-backup/backup-count.conf
```


## Optional - set a crontab job

### Move the script somewhere safe for a custom cron time - make sure to not have the .sh extension
### Or move the script in a already predefined crontab directory like /etc/cron.daily or /etc/cron.weekly
```sh
mv backup.sh /etc/server-backup/scripts/backup
```
```sh
mv backup.sh /etc/cron.weekly
```
### Set a crontab job
```sh
crontab -e
```
```sh
* 4 */1 3 * /etc/server-backup/scripts/backup # example. use https://crontab.guru
```
