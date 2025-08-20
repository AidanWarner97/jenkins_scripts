#!/bin/bash

# Updating from source
echo "Creating environment from source snapshot..."
rsync -ah --delete /mnt/evo/11-source/ /mnt/evo/11-build/