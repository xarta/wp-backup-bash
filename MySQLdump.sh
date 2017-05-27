#!/bin/bash

# 2017, Feb: dave@xarta.co.uk
#---------------------------------

# daily, weekly, monthly use simlink name "0" e.g. bkup_daily.sh
# e.g. avoid duplicate code - just one back-up script (+ delete-files script)
# bkup_daily
# bkup_monthly
# bkup_weekly

#TODO look at including DB_BKUP_FOLDER etc in the basename
filename=$(basename "$0")
extension=${filename##*.}
type=${filename%.*}

#---------------------------------

# TODO look at using a config file for paths
DB_BKUP_FOLDER=blog.xarta.co.uk
TARGET_PATH=/mnt/hgfs/SHARED-UBUNTU/$DB_BKUP_FOLDER
DB_NAME=xarta_blog
# TODO look at reading-in password from elsewhere - some kind of vault or something
read -d $'\x04' DB_PASS < /home/davros/WPbackups/MySQLpassword

today=`date '+%Y_%m_%d__%H_%M_%S'`;
targetoutputsql=$TARGET_PATH/$type/sql_$today.sql.gz


# (mySql root and root-password)
/usr/bin/mysqldump -u root -p$DB_PASS  $DB_NAME | gzip > $targetoutputsql

wp_backup_log=$TARGET_PATH/WPbackup.log

if [ -f $targetoutputsql ]; then
    if [ $type == "bkup_weekly" ] || [ $type == "bkup_monthly" ]; then
	    # back-up WP files too (organically bolted-on)
	    SITE_PATH=/var/www/html
	    targetoutputfiles1=$TARGET_PATH/$type/fS1_$today.tar.gz
	    find $SITE_PATH -mindepth 2 -type f -print0 | tar \
		 --exclude="updraft" --exclude="wp-admin" --exclude="wp-includes" \
		 -czvf $targetoutputfiles1 --null -T -

	    # TODO COMBINE BELOW WITH ABOVE AS ONE find SOMEHOW
	    targetoutputfiles2=$TARGET_PATH/$type/fS2_$today.tar.gz
	    find $SITE_PATH  -maxdepth 1 \( -name "wp-config.php" -o -name ".htaccess" \) \
		 -type f -print0 | tar \
		 -czvf $targetoutputfiles2 --null -T -


	    # delete old backups, if any
	    /home/davros/WPbackups/DeleteBackUps.sh
    fi
else
    # TODO error-handling
    logger -s "ERROR: $targetoutputsql" 2>> $wp_backup_log
    echo "ERROR: $targetoutputsql"
fi



# notes on sudo crontab -e
# if owner of this file MySQLdump.sh is root, even if simlink bkup_daily is me,
# ... then use "sudo" for crontab -e so runs as root (for mysqldump command)
# ... I'm just giving MySQLdump.sh and symlinks rwx at least for owner, for now

# Example of job definition (copied off internet somewhere):
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed

# *  22 *  *  * /home/davros/WPbackups/bkup_daily.sh     ... symlink to MySQLdump.sh
# *  *  *  *  0 /home/davros/WPbackups/bkup_weekly.sh    ... symlink to MySQLdump.sh
# *  *  *  1  * /home/davros/WPbackups/bkup_monthly.sh   ... symlink to MySQLdump.sh
