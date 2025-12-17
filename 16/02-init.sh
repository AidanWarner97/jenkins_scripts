#!/bin/bash

repo init -u https://github.com/Evolution-X/manifest -b bka --git-lfs
repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags

mkdir -p /home/shared/11-source/vendor/evolution-priv/
rsync -av /home/shared/vendor/evolution-priv/keys/ /home/shared/11-source/vendor/evolution-priv/keys/
