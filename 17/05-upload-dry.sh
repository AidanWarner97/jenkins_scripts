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

# Show what main rom would be uploaded
echo "Would upload main rom:"
echo "  Source: out/target/product/$device/EvolutionX*.zip"
echo "  Destination: b2:evo-downloads/$device/$date/"
echo " "

# Identify and show initial install images that would be uploaded
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

# Show what images would be uploaded
echo "Would upload the following images:"
for image in $initial_images; do
    image_path="out/target/product/$device/$image.img"
    if [ -f "$image_path" ]; then
        echo "  ✓ $image"
        echo "    Source: $image_path"
        echo "    Destination: b2:evo-downloads/$device/$date/$image/"
    else
        echo "  ✗ $image (file not found: $image_path)"
    fi
    echo " "
done

echo "Dry run complete. No files were actually uploaded."
