#!/bin/bash

echo "################################################################"

#echo "It's $(date +%A)"
#echo "System is: $HOSTNAME"
#echo "User is: $USER"

#echo $alt
# For some reason script is treating alt as true
alt=false

echo "Updating SyncSaves from NAS..."

TESTING=false
if $TESTING; then
  echo WARNING - TESTING MODE ON - NOT UPDATING...
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
### Manually set script directory
#SCRIPT_DIR=/home/deck/Documents/scripts/SyncSaves
EXPECTED_DIR=/home/deck/Documents/scripts/SyncSaves
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

# Set update dir manually
#UPDATE_DIR=/home/deck/mnt/xtra/scripts/SyncSaves/
UPDATE_DIR=$lin_cloud_drive/scripts/SyncSaves/

if $TESTING; then
    echo "rsync --update -av --exclude 'BAK' $UPDATE_DIR $SCRIPT_DIR"
else
    rsync --update -av --exclude 'BAK' $UPDATE_DIR $SCRIPT_DIR
fi

echo SCRIPT UPDATED

echo "################################################################"

echo Last update by $USER on $(date) - TESTING: $TESTING >> $SCRIPT_DIR/sync_saves.log
#echo "Writing to log in X"
#LOG_PATH=/home/deck/mnt/xtra/scripts/SyncSaves/sync_saves.log
#echo "SyncSaves updated by $USER on $(date) successfully." >> $LOG_PATH

exit
