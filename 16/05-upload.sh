#!/bin/bash

# Enable extended globbing
shopt -s extglob

device=$1
vanilla=$2

# Check if build was vanilla
if [ "$vanilla" == "VANILLA" ]; then
    filename=$(basename out/target/product/$device/EvolutionX-*Vanilla*.zip)
else
    filename=$(basename out/target/product/$device/EvolutionX-*.zip 2>/dev/null | grep -v Vanilla | head -1)
fi

# Extract Android Version from json
version=$(echo $filename | cut -d "-" -f 2| cut -d "." -f 1)
date=$(echo $filename | cut -d "-" -f 3 | cut -d "." -f 1)

# Check if filename contains "Vanilla" and set folder accordingly
if [[ "$vanilla" == "VANILLA" ]]; then
    folder="${date}_Vanilla"
    echo "Vanilla build - using folder: $folder"
else
    folder="$date"
    echo "GAPPS build - using folder: $folder"
fi

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
rclone copy out/target/product/$device/$filename b2:evo-downloads/$device/$folder/ -P
echo "  ✓ Main ROM uploaded"
echo " "

# Upload JSON
echo "Uploading OTA JSON..."
cp out/target/product/$device/$device.json out/target/product/$device/$folder.json
rclone copy out/target/product/$device/$folder.json b2:evo-downloads/$device/ -P
echo "  ✓ OTA JSON uploaded"
echo " "

# Identify and upload initial install images
wget https://mm-dashboard.evolution-x.org/json/all_images.json -O /opt/flask-list/all_images.json 2>&1 >/dev/null
json="/opt/flask-list/all_images.json"

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
    rclone copy out/target/product/$device/$image.img b2:evo-downloads/$device/$folder/$image/ -P
    echo "  ✓ $image uploaded"
    echo " "
done
