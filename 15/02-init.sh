#!/bin/bash

repo init -u https://github.com/Evolution-X/manifest -b vic --depth=1 --git-lfs
repo sync -c -j$(nproc --all) --no-clone-bundle --no-tags --optimized-fetch --prune

git clone git@github.com:Evolution-X/vendor_evolution-priv_keys.git /home/shared/10-source/vendor/evolution-priv/keys/
