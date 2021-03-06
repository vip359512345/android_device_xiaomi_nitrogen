#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

set -e

DEVICE=nitrogen
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

LINEAGE_ROOT="$MY_DIR"/../../..

HELPER="$LINEAGE_ROOT"/vendor/lineage/build/tools/extract_utils.sh
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
. "$HELPER"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

while [ "$1" != "" ]; do
    case $1 in
        -n | --no-cleanup )     CLEAN_VENDOR=false
                                ;;
        -s | --section )        shift
                                SECTION=$1
                                CLEAN_VENDOR=false
                                ;;
        * )                     SRC=$1
                                ;;
    esac
    shift
done

if [ -z "$SRC" ]; then
    SRC=adb
fi

# Initialize the helper
setup_vendor "$DEVICE" "$VENDOR" "$LINEAGE_ROOT" false "$CLEAN_VENDOR"

extract "$MY_DIR"/proprietary-files.txt "$SRC" "$SECTION"

# DEVICE_BLOB_ROOT="$LINEAGE_ROOT"/vendor/"$VENDOR"/"$DEVICE"/proprietary

# sed -i \
#     's/\/system\/etc\//\/vendor\/etc\//g' \
#     "$DEVICE_BLOB_ROOT"/vendor/lib/libmmcamera2_sensor_modules.so

#
# Use 8.1 libicuuc.so and libminikin.so for libMiCameraHal.so
#
# ICUUC_V27="$DEVICE_BLOB_ROOT"/vendor/lib/libicuuc-v27.so
# MINIKIN_V27="$DEVICE_BLOB_ROOT"/vendor/lib/libminikin-v27.so
# patchelf --set-soname libicuuc-v27.so "$ICUUC_V27"
# patchelf --set-soname libminikin-v27.so "$MINIKIN_V27"

# MI_CAMERA_HAL="$DEVICE_BLOB_ROOT"/vendor/lib/libMiCameraHal.so
# patchelf --replace-needed libicuuc.so libicuuc-v27.so "$MI_CAMERA_HAL"
# patchelf --replace-needed libminikin.so libminikin-v27.so "$MI_CAMERA_HAL"

#
# Remove unused linkage from camera.sdm660.so to avoid conflicts
#
# CAMERA_SDM660="$DEVICE_BLOB_ROOT"/vendor/lib/hw/camera.sdm660.so
# patchelf --remove-needed libicuuc.so "$CAMERA_SDM660"
# patchelf --remove-needed libminikin.so "$CAMERA_SDM660"

#patchelf --replace-needed android.frameworks.sensorservice@1.0.so android.frameworks.sensorservice@1.0-v27.so $DEVICE_BLOB_ROOT/vendor/lib/libvideorefiner.so

"$MY_DIR"/setup-makefiles.sh

DEVICE_BLOB_ROOT="$LINEAGE_ROOT"/vendor/"$VENDOR"/"$DEVICE"/proprietary

# CAMERA_HAL="$DEVICE_BLOB_ROOT"/vendor/lib/hw/camera.sdm660.so

# sed -i \
#     -e 's/\xe0\x6d\x01\x28\x0b\xd0/\x00\xbf\x00\xbf\x1f\xe0/' \
#     "$CAMERA_HAL"

patchelf --remove-needed vendor.xiaomi.hardware.mtdservice@1.0.so "$DEVICE_BLOB_ROOT"/vendor/bin/mlipayd@1.1
patchelf --remove-needed vendor.xiaomi.hardware.mtdservice@1.0.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libmlipay.so
patchelf --remove-needed vendor.xiaomi.hardware.mtdservice@1.0.so "$DEVICE_BLOB_ROOT"/vendor/lib64/libmlipay@1.1.so

# sed -i "s|\/data\/vendor\/radio\/modem_config\/mcfg_hw\/|\/data\/vendor\/modem_config\/mcfg_hw\/\x00\x00\x00\x00\x00\x00|g" \
#     "$DEVICE_BLOB_ROOT"/vendor/lib64/libril-qc-hal-qmi.so
# sed -i "s|\/data\/vendor\/radio\/modem_config\/mcfg_sw\/|\/data\/vendor\/modem_config\/mcfg_sw\/\x00\x00\x00\x00\x00\x00|g" \
#     "$DEVICE_BLOB_ROOT"/vendor/lib64/libril-qc-hal-qmi.so
# sed -i "s|\/data\/vendor\/radio\/modem_config\/|\/data\/vendor\/modem_config\/\x00\x00\x00\x00\x00\x00|g" \
#     "$DEVICE_BLOB_ROOT"/vendor/lib64/libril-qc-hal-qmi.so
