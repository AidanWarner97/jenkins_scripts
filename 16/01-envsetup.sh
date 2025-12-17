#!/bin/bash

# Updating from source
echo "Creating environment from source snapshot..."
rsync -ah --delete /home/shared/11-source/ /home/shared/11-build/
