#!/bin/bash

# ANDROID_NDK
# CMAKE_HOME

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)";
SCRIPT_DIR="${SCRIPT_DIR//\\//}";

source "$SCRIPT_DIR/LoadCMakeEnvs.sh" ;
source "$SCRIPT_DIR/../AndroidSetting.sh";

# android ndk
if [ -z "$ANDROID_NDK" ]; then
    echo "ANDROID_NDK is not set ,please input the ANDROID_NDK(which contains build/cmake/android.toolchain.cmake) and then press ENTER.";
    read -r -p "ANDROID_NDK: " ANDROID_NDK;
    ANDROID_NDK="${ANDROID_NDK//\\/\/}";
fi

export ANDROID_NDK ;

if [ ! -e "$ANDROID_NDK/build/cmake/android.toolchain.cmake" ]; then
    echo "ANDROID_NDK($ANDROID_NDK) is invalid, please check the configure.";
    exit 2;
fi

if [ -z "$BUILD_ROOT_PREFIX" ]; then
    BUILD_ROOT_PREFIX="$SCRIPT_DIR";
fi

