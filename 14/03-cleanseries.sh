#!/bin/bash

device=$1

export CCACHE_MAXSIZE=100G

source build/envsetup.sh &&
lunch lineage_$device-userdebug &&
m installclean
