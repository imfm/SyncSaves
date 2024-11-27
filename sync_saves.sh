#!/bin/bash

echo "################################################################"

#echo "It's $(date +%A)"
echo "Sytem is: $HOSTNAME"
echo "User is: $USER"
#echo "Current directory is: $PWD"
echo ""

TESTING=false
if $TESTING; then
 echo WARNING - TESTING MODE ON - FILES WILL NOT BE SYNCED...
fi

#echo "param1: $1"
if [ -z "$1" ] 
then
 echo "No parameter1, defaulting to -backup"
 op='-backup'
else
 op=$1
fi
if [ $op == '-update' ]
then
 echo "Operation is Update"
else
 echo "Operation is Backup"
fi

if [ -z "$2" ]
then
 ##echo "Parameter2 is empty"
 alt=false
else
 ##echo "Parameter2 is $2"
 alt=$2
fi

#SCRIPT_DIR=/home/deck/Documents/scripts/SyncSaves
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
EXPECTED_DIR=SCRIPT_DIR
### Manually set script directory
### Sometimes the Steam Deck starts in the wrong directory and can't find common.cfg or sync_saves.csv. As a horrible workaround, set script directory here. 
#EXPECTED_DIR=/home/deck/Documents/scripts/SyncSaves
if [ $SCRIPT_DIR != $EXPECTED_DIR ]
then
 echo "Warning, SCRIPT_DIR is not pointing to EXPECTED_DIR location: $SCRIPT_DIR"
 echo "Try to set SCRIPT_DIR manually to: $EXPECTED_DIR"
 SCRIPT_DIR=$EXPECTED_DIR
 echo "SCRIPT_DIR is now pointing to: $SCRIPT_DIR"
else
 echo "SCRIPT_DIR is Okay!"
fi
echo ""

IFS='='
while read -r var val
do
 declare $var=$val
#done < common.cfg
done < <(tr -d '\r' <$SCRIPT_DIR/common.cfg)
#echo "lin_user: $lin_user"
echo "cloud_path: $cloud_path"
if $alt; then
 echo "Using alt cloud path"
 lin_cloud_drive=$alt_lin_cloud_drive
 echo "lin_cloud_drive: $lin_cloud_drive"
else
 echo "lin_cloud_drive: $lin_cloud_drive"
fi
echo ""

#echo "Mount Cloud Drive (X/Y)"
#mount /home/deck/mnt/xtra
echo "Is NAS is mounted?"
echo "NAS should be mounted at: $lin_cloud_drive"
if mountpoint -q $lin_cloud_drive
then
   echo "NAS IS mounted!"
else
    echo "NAS is NOT mounted. Trying to mount..."
    mount $lin_cloud_drive
    echo $(mountpoint $lin_cloud_drive)
fi
#echo $(mountpoint /home/deck/mnt/xtra)
#mountpoint /home/deck/mnt/xtra
#mount $lin_cloud_drive
#echo ""

echo "READING GAMES DATABASE FROM SCRIPT_DIR: "
CONFIG_PATH=$SCRIPT_DIR/sync_saves.csv
### Not sure what this does, but we need it
exec < $CONFIG_PATH
#exec < /home/deck/Documents/scripts/SyncSaves/sync_saves.csv
#exec < <(tr -d '\r' <$SCRIPT_DIR/sync_saves.csv)
read header
while IFS="," read -r a b c d e f g h i j k l
do
 echo "game_name: $a"
 #echo "lin_drive: $d"
 #echo "win_path: $e"
 #echo "lin_path: $f"
 #echo "lin_pfx_user: $g"
 #echo "all_path: $h"
 #echo "save_folder: $i"
 #echo "game_user: $j"
 #echo "skip: $k"
 #echo "exclude_files: $l"
 #echo ""
 
 game_name=${a}
 skip=${k}
 
 exclude_files="${l//[$'\t\r\n']}"
 exclude_files="'$exclude_files'"
 
 full_path="${d}${f}${h}${i}"
 full_path="${full_path//[$'\t\r\n']}"
 full_path="${full_path}\\"
 #echo "full path: $full_path"
 
 full_path="${full_path/'{win_path}'/$e}"
 full_path="${full_path/'{lin_user}'/$USER}"
 full_path="${full_path/'{lin_pfx_user}'/$g}"
 full_path="${full_path/'{game_user}'/$j}"
 full_path="${full_path/'{win_user}'/$g}"
 #echo "full path rep: $full_path"
 full_path=$(echo $full_path | sed -r 's|\{NA\}||g')
 full_path=$(echo $full_path | sed -r 's|\\\\|\\|g')
 full_path=$(echo $full_path | sed -r 's/\\/\//g')
 
 full_cloud_path="${lin_cloud_drive}${cloud_path}\\${a}\\"
 full_cloud_path=$(echo $full_cloud_path | sed -r 's|\\\\|\\|g')
 full_cloud_path=$(echo $full_cloud_path | sed -r 's/\\/\//g')

 #echo "full path : $full_path"
 #echo "full cloud: $full_cloud_path"
 
 backup_path1=${lin_cloud_drive}${cloud_path}\\backup1\\${a}
 backup_path1="${backup_path1//[$'\t\r\n']}"
 backup_path1="${backup_path1}\\"
 backup_path1=$(echo $backup_path1 | sed -r 's|\\\\|\\|g')
 backup_path1=$(echo $backup_path1 | sed -r 's/\\/\//g')
 backup_path2=${lin_cloud_drive}${cloud_path}\\backup2\\${a}
 backup_path2="${backup_path2//[$'\t\r\n']}"
 backup_path2="${backup_path2}\\"
 backup_path2=$(echo $backup_path2 | sed -r 's|\\\\|\\|g')
 backup_path2=$(echo $backup_path2 | sed -r 's/\\/\//g')
 backup_only=0
 #echo "backup_path1: $backup_path1"
 #echo "backup_path2: $backup_path2"
 
 if test -d $full_path; then
	if [ $skip == 1 ]; then
		echo "SKIPPING: $a - $full_path"
	elif $TESTING; then
		echo "rsync --update -av --exclude $exclude_files $backup_path1 $backup_path2"
		echo "rsync --update -av --exclude $exclude_files $full_cloud_path $backup_path1"
		echo "rsync --update -av --exclude $exclude_files $full_path $full_cloud_path"
		echo "rsync --update -av --exclude $exclude_files $full_cloud_path $full_path"
		echo TESTING MODE ON - FILES NOT SYNCED...
		if [ "$op" == "-backup" ] 
		then
			echo "OP IS BACKUP"
		elif [ "$op" == "-update" ] 
		then
			echo "OP IS update"
		else
			echo "ERROR: Unknown Operation"
		fi
	else
		if [ "$op" == "-backup" ] 
		then
			mkdir -p $full_cloud_path
			DIFFS="$(diff -qr $full_path $full_cloud_path)"
			echo "DIFFS: $DIFFS"
			#if $diffs >/dev/null; then
			if [ "$DIFFS" == "" ] 
			then
				echo "No Backups Needed: $full_path";
			else
				echo "backing up previous backups..."
				rsync --update -va --exclude $exclude_files $backup_path1 $backup_path2
				echo "backing up previous saves..."
				rsync --update -va --exclude $exclude_files $full_cloud_path $backup_path1
				echo "backing up current saves..."
				rsync --update -va --exclude $exclude_files $full_path $full_cloud_path
			fi
		elif [ "$op" == "-update" ]
		then
			if [ $backup_only == 1 ]
			then
				echo "..."
				echo "$game_name is set to backup ONLY"
				echo "..."
			else
				echo "updating current saves..."
				rsync --update -va --exclude $exclude_files $full_cloud_path $full_path
			fi
		else
			echo "ERROR: Unknown Operation"
		fi
 fi
 echo ""
 else
 echo "-$a not found, skipping: $full_path"
 echo ""
 fi

#done < <(tail -n +2 sync_saves.csv)
done < <(tail -n +2 $CONFIG_PATH)

echo "Writing to log at $SCRIPT_DIR"
echo "Last sync - $op - by $USER on $(date) - TESTING: $TESTING" >> $SCRIPT_DIR/sync_saves.log

LOG_PATH="${lin_cloud_drive}${cloud_path}/sync_saves.log"
LOG_PATH=$(echo $LOG_PATH | sed -r 's|\\\\|\\|g')
LOG_PATH=$(echo $LOG_PATH | sed -r 's/\\/\//g')
#SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
#$echo "Script is located in: $SCRIPT_DIR"
echo "Writing to log at $LOG_PATH"
echo "Last sync - $op - by $USER on $(date) - TESTING: $TESTING" >> $LOG_PATH

if $TESTING; then
 echo TESTING MODE ON - FILES WERE NOT SYNCED...
fi

echo SAVES SYNCHRONIZED

echo "################################################################"

#echo "Is x is mounted?"
#echo $(mountpoint /home/deck/mnt/xtra)
#mountpoint /home/deck/mnt/xtra

exit
