#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "Script is located in: $SCRIPT_DIR"
echo "Calling update script..."
#source $SCRIPT_DIR/update_ss.sh
/bin/bash $SCRIPT_DIR/update_ss.sh
echo "Calling sync script..."
#source $SCRIPT_DIR/sync_saves.sh
/bin/bash $SCRIPT_DIR/sync_saves.sh $1
echo "Updated and Synchronized"
exit
