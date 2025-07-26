#!/bin/bash

device=$1

target=$(tail -n 1 vendor/lineage/vars/aosp_target_release | cut -d "=" -f 2)

export EVO_BUILD_TYPE=Official
export CCACHE_MAXSIZE=300G

export CFLAGS="$CFLAGS -isystem /usr/include/x86_64-linux-gnu"
export CXXFLAGS="$CXXFLAGS -isystem /usr/include/x86_64-linux-gnu"
export KERNEL_CFLAGS="$KERNEL_CFLAGS -isystem /usr/include/x86_64-linux-gnu"
export KCFLAGS="$KCFLAGS -isystem /usr/include/x86_64-linux-gnu"

source build/envsetup.sh &&
lunch lineage_$device-$target-userdebug &&
m evolution
