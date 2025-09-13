#!/bin/bash

device=$1

# Extract Android Version from json
filename=$(echo out/target/product/$device/EvolutionX-*.zip)
version=$(echo $filename | cut -d "-" -f 2| cut -d "." -f 1)
date=$(echo $filename | cut -d "-" -f 3 | cut -d "." -f 1)

# Check if filename contains "Vanilla" and set folder accordingly
if [[ "$filename" == *"Vanilla"* ]]; then
    folder="${date}_Vanilla"
    echo "Vanilla build detected - using folder: $folder"
else
    folder="$date"
    echo "Standard build detected - using folder: $folder"
fi

# Upload main rom
echo "Uploading main rom..."
rclone copy out/target/product/$device/EvolutionX*.zip b2:evo-downloads/$device/$folder/ -P
echo " "

# Identify and upload initial install images
json="evolution/OTA/builds/$device.json"

# Extract initial_installation_images from json
initial_images=$(jq -r '.response[0].initial_installation_images[]' "$json")

# Upload found images
for image in $initial_images; do
    echo "Uploading $image..."
    rclone copy out/target/product/$device/$image*.img b2:evo-downloads/$device/$folder/$image/ -P
    echo " "
done
