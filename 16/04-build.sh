#!/bin/bash

device=$1
buildtype=$2
buildformat=$3

target=$(tail -n 1 vendor/lineage/vars/aosp_target_release | cut -d "=" -f 2)

if [ "$buildtype" == "userdebug" ]; then
    export EVO_BUILD_TYPE=Official
else
    export EVO_BUILD_TYPE=Unofficial
fi

export CCACHE_MAXSIZE=300G

export CFLAGS="$CFLAGS -isystem /usr/include/x86_64-linux-gnu"
export CXXFLAGS="$CXXFLAGS -isystem /usr/include/x86_64-linux-gnu"
export KERNEL_CFLAGS="$KERNEL_CFLAGS -isystem /usr/include/x86_64-linux-gnu"
export KCFLAGS="$KCFLAGS -isystem /usr/include/x86_64-linux-gnu"

# export RBE vars
export USE_RBE=1

export RBE_CXX_EXEC_STRATEGY=local
export RBE_D8_EXEC_STRATEGY=local
export RBE_JAVAC_EXEC_STRATEGY=local
export RBE_METALAVA_EXEC_STRATEGY=local
export RBE_R8_EXEC_STRATEGY=local
export RBE_RUST_EXEC_STRATEGY=local

export RBE_CXX=1
export RBE_D8=1
export RBE_JAVAC=1
export RBE_METALAVA=1
export RBE_R8=1
export RBE_RUST=1

export RBE_instance=evolutionx
export RBE_service=127.0.0.1:9092
export RBE_service_no_security=true
export RBE_service_no_auth=true
export RBE_DIR=prebuilts/remoteexecution-client/live


source build/envsetup.sh &&
lunch lineage_$device-$target-$buildtype &&

if [[ "$buildformat" == "Installclean" ]]; then
    m installclean
fi

google_devices="caiman comet tokay komodo tegu shiba husky akita tangorpro felix lynx panther cheetah bluejay oriole raven sargo bonito blueline crosshatch"

if [[ " $google_devices " == *" $device "* ]]; then
    SOURCE_PATH="vendor/gms/product/packages/privileged_apps/"
    TARGET_ROOT="vendor/google"
    TARGET_SUBPATH="proprietary/product/priv-app"

    for source_dir in "$SOURCE_PATH"/*; do
        base_name=$(basename "$source_dir")

        target_dirs=$(find "$TARGET_ROOT" -type d -path "*/$TARGET_SUBPATH/$base_name")

        if [[ -n "$target_dirs" ]]; then
            echo "Match found for $base_name in $TARGET_ROOT. Removing $source_dir..."
            rm -rf "$source_dir"
        else
            echo "No match found for $base_name. Keeping $source_dir."
        fi
    done

else
    echo "Device $device is not in the list of Google devices, no need for cleanup."
fi

m evolution -j$(nproc --all)

