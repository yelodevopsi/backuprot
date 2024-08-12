# backuprot

Takes complete backup of folder-tree and all files in it and create log files.

```
USAGE:
    backuprot [OPTIONS] /source_folder/ /destination_folder/

Back up an entire folder, create a tgz archive, and perform x-day rotation of backups.
You must provide source and destination folders.

OPTIONS:
    -p Specify Rotation period in days - default is $ROTATE_PERIOD

EXAMPLES:
    backuprot -p 3 [/source_folder/] [/destination_folder/]
```

## Install

- Set ROTATE_PERIOD, DESTINATION_FOLDER and SOURCE_FOLDER in backuprot.sh
- Run `make install` to update

## Schedule backup with Crontab

Open Crontab for e.g. webserver user:

```crontab -e: -u www-data```

Append to the bottom of the file:

```
#### Backup every ~2nd day at 04:00 AM.
0 4 * * SUN,TUE,THU backuprot /var/www/ /var/backups/webfolder/daily/ >> /var/log/backuprot/daily.log 2>&1

#### Weekly backup is running every monday at 06:00 AM. Check backuprot
#### for max number of -p rotation backups that should be kept.
0 6 * * 1 backuprot /var/www/ /var/backups/webfolder/weekly/ >> /var/log/backuprot/weekly.log 2>&1
```

## To edit/update backup

- Edit backuprot.sh file.
- Run `make install`
