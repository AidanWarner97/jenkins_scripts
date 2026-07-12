#!/bin/bash

device="$1"

# Set resource for rsync
export RSYNC_MAX_ALLOC=4G

# Updating from source
echo "Creating environment from source snapshot..."
rsync -ah --delete /home/shared/11-source/ /home/shared/11-build/

# Remove build data json
if [ -f ~/$device.json ]; then
    rm ~/$device.json
fi