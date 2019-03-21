#!/bin/bash

# ANDROID_NDK
# CMAKE_HOME

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)";
SCRIPT_DIR="${SCRIPT_DIR//\\//}";
source "$SCRIPT_DIR/../AndroidSetting.sh";

# cmake
if [ -z "$CMAKE_HOME" ]; then
    CMAKE_BIN="$(which cmake 2>&1)";
    if [ $? -eq 0 ]; then
        CMAKE_HOME="$(dirname "$(dirname "$CMAKE_BIN")")" ;
    else
        echo "Executable cmake not found ,please input the CMAKE_HOME(which contains bin/cmake) and then press ENTER.";
        read -r -p "CMAKE_HOME: " CMAKE_HOME;
        CMAKE_HOME="${CMAKE_HOME//\\/\/}";
    fi
fi

if [ ! -e "$CMAKE_HOME/bin/cmake" ]; then
    echo "Can not find $CMAKE_HOME/bin/cmake , try $CMAKE_HOME/bin/cmake.exe.";
    if [ ! -e "$CMAKE_HOME/bin/cmake.exe" ]; then
        echo "Can not find cmake in $CMAKE_HOME, exit now.";
        exit 1;
    fi
fi

export CMAKE_HOME ;

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

for ARCH in $ANDROID_ARCHS; do
    export SYSTEM_NAME="Android-$ARCH" ;
    export ARCH=$ARCH ;
    chmod +x "$SCRIPT_DIR/GenerateAndroidGo.sh" ;
    "$SCRIPT_DIR/GenerateAndroidGo.sh" ;

    LAST_EXIT_CODE=$?;
    if [ $LAST_EXIT_CODE -ne 0 ]; then
        exit $LAST_EXIT_CODE;
    fi
done
