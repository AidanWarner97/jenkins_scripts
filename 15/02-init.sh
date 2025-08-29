#!/bin/bash

repo init -u https://github.com/Evolution-X/manifest -b vic --git-lfs
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

git clone git@github.com:Evolution-X/vendor_evolution-priv_keys.git /mnt/evo/10-source/vendor/evolution-priv/keys/