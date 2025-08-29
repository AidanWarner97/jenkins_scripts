#!/bin/bash

# Updating from source
echo "Creating environment from source snapshot..."
rsync -ah --delete /mnt/evo/10-source/ /mnt/evo/10-build/