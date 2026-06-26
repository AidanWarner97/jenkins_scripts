#!/bin/bash

# Set resource for rsync
export RSYNC_MAX_ALLOC=4G

# Updating from source
echo "Creating environment from source snapshot..."
rsync -ah --delete /home/shared/12-source/ /home/shared/12-build/
