#!/bin/bash

repo init -u https://github.com/Evolution-X/manifest -b bka --git-lfs
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

rsync -av /mnt/evo/vendor/evolution-priv/keys/ /mnt/evo/11-source/vendor/evolution-priv/keys/
