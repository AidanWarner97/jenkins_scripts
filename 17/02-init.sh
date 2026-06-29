#!/bin/bash

repo init -u https://github.com/Evolution-X/manifest -b cnb --depth=1 --git-lfs
repo sync -c -j$(nproc --all) --no-clone-bundle --no-tags --optimized-fetch --prune

git clone git@github.com:Evolution-X/vendor_evolution-priv_keys_16_and_up.git -b cnb /home/shared/12-source/vendor/evolution-priv/keys/
