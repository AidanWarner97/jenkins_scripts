#!/bin/bash

device="$1"

# Updating from source
echo "Creating environment from source snapshot..."
rsync -ah --delete /home/shared/10-source/ /home/shared/10-build/

# Remove build data json
rm "$device.json"