#!/bin/bash
# delete old WordPress back-ups, but only if there are existing back-ups
# only daily and weekly (not touching monthly)
# 2017, Feb: dave@xarta.co.uk  (first "proper" BASH script - woohooo!)
# REMEMBER DAVE: EVERYTHING IS A STRING!!!

# nb: might change back-ups in the future to use local folder, and then rsync over ssh

bkup_daily='/mnt/hgfs/SHARED-UBUNTU/blog.xarta.co.uk/bkup_daily'
bkup_weekly='/mnt/hgfs/SHARED-UBUNTU/blog.xarta.co.uk/bkup_weekly'

# doing this "assignment" way to avoid empty string from wc -l (instead of "0").
count_bkup_d_before=$(find $bkup_daily -type f | wc -l)
count_bkup_w_before=$(find $bkup_weekly -type f | wc -l)

if [ $count_bkup_d_before -gt "14" ]; then
    find $bkup_daily -mtime +13 -type f -delete
fi

if [ $count_bkup_w_before -gt "5" ]; then
    find $bkup_weekly -mtime +34 -type f -delete
fi

count_bkup_d_after=$(find $bkup_daily -type f | wc -l)
count_bkup_w_after=$(find $bkup_weekly -type f | wc -l)

# Making separate log in shared folder, so Acronis on host of shared-folder backs-up online, too
# (logger -s "blah" 2>>$something etc. will make a user thingy entry in syslog AND $something)
wp_backup_log="/mnt/hgfs/SHARED-UBUNTU/blog.xarta.co.uk/WPbackup.log"
logger -s "Deleting old WP backup files" 2>> $wp_backup_log

logger -s "WP daily bkup files: before $count_bkup_d_before, after $count_bkup_d_after" 2>> \
           $wp_backup_log

logger -s "WP weekly bkup files: before $count_bkup_w_before, after $count_bkup_w_after" 2>> \
           $wp_backup_log
