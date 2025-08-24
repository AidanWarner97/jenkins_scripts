#!/bin/bash

device=$1

# Extract Android Version from json
filename=$(echo out/target/product/$device/EvolutionX-*.zip)
version=$(echo $filename | cut -d "-" -f 2| cut -d "." -f 1)
date=$(echo $filename | cut -d "-" -f 3 | cut -d "." -f 1)

# Map Android version numbers to branch names
case $version in
    "16")
        branch="bka"
        ;;
    "15")
        branch="udc"
        ;;
    "14")
        branch="vic"
        ;;
    *)
        echo "Error: Unknown Android version '$version'. Supported versions: 16 (bka), 15 (udc), 14 (vic)"
        exit 1
        ;;
esac

echo "Android Version: $version -> Branch: $branch"

# Upload main rom
echo "Uploading main rom..."
rclone copy out/target/product/$device/EvolutionX*.zip b2:evo-downloads/$device/$date/ -P
echo "  ✓ Main ROM uploaded"
echo " "

# Upload JSON
echo "Uploading OTA JSON..."
rclone copy out/target/product/$device/$device.json b2:evo-downloads/$device/$date.json -P
echo "  ✓ OTA JSON uploaded"
echo " "

# Identify and upload initial install images
json="/opt/device_install_images/all_images.json"

# Extract initial_installation_images from json for specific device and branch
initial_images=$(jq -r --arg device "$device" --arg branch "$branch" '.[] | select(.device == $device) | .versions[$branch][]?' "$json")

# If no images found for the specific branch, try vanilla variant
if [ -z "$initial_images" ]; then
    echo "No images found for branch '$branch', trying vanilla variant..."
    vanilla_branch="${branch}-vanilla"
    initial_images=$(jq -r --arg device "$device" --arg branch "$vanilla_branch" '.[] | select(.device == $device) | .versions[$branch][]?' "$json")
    
    if [ -n "$initial_images" ]; then
        echo "Found images using vanilla branch: $vanilla_branch"
        branch=$vanilla_branch
    fi
fi

if [ -z "$initial_images" ]; then
    echo "Error: No images found for device '$device' with branch '$branch' or '${branch}-vanilla'"
    exit 1
fi

# Upload found images
for image in $initial_images; do
    echo "Uploading $image..."
    rclone copy out/target/product/$device/$image.img b2:evo-downloads/$device/$date/$image/ -P
    echo "  ✓ $image uploaded"
    echo " "
done
