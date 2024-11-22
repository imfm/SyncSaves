#!/bin/bash
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "Backing up saves..."
echo "Script is located in: $SCRIPT_DIR"
/bin/bash $SCRIPT_DIR/sync_saves.sh
exit