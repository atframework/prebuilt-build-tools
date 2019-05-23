#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)";
SCRIPT_DIR="${SCRIPT_DIR//\\//}";

source "$SCRIPT_DIR/LoadAndroidEnvs.sh";

if [ -z "$ARCH" ]; then
    echo "ARCH is not set ,please input the ARCH(x86/x86_64/armeabi-v7a/arm64-v8a) and then press ENTER.";
    read -r -p "ARCH: " ARCH;
fi

if [ "${ARCH:0:7}" == "armeabi"  ]; then
    PROJECT_ATFRAME_TARGET_CPU_ABI="armv7";
elif [ "${ARCH:0:5}" == "arm64"  ]; then
    PROJECT_ATFRAME_TARGET_CPU_ABI="aarch64";
elif [ "$ARCH" == "x86"  ]; then
    PROJECT_ATFRAME_TARGET_CPU_ABI="x86";
elif [ "$ARCH" == "x86_64"  ]; then
    PROJECT_ATFRAME_TARGET_CPU_ABI="x86_64";
elif [ "$ARCH" == "mips"  ]; then
    PROJECT_ATFRAME_TARGET_CPU_ABI="mips";
elif [ "$ARCH" == "mips64"  ]; then
    PROJECT_ATFRAME_TARGET_CPU_ABI="mips64";
else
    echo "ARCH($ARCH) is invalid, exit now.";
    exit 2;
fi

if [ -z "$SYSTEM_NAME" ]; then
    SYSTEM_NAME="Android-$ARCH";
fi

# prefer to use ninja
CMAKE_GENERATOR="MSYS Makefiles";
"$CMAKE_BIN" --help | grep "$CMAKE_GENERATOR" > /dev/null 2>&1;
if [ $? -ne 0 ]; then
    CMAKE_GENERATOR="Unix Makefiles";
fi

printf "Checking ninja ...              ";
USE_NINJA=0;
NINJA_BIN="$(which ninja 2>/dev/null)";
if [ $? -eq 0 ]; then
    USE_NINJA=1;
    CMAKE_GENERATOR="Ninja";
else
    NINJA_BIN="$(which ninja-build 2>/dev/null)";
    if [ $? -eq 0 ]; then
        USE_NINJA=2;
        CMAKE_GENERATOR="Ninja";
    else
        which make > /dev/null 2>&1;
        if [ $? -ne 0 ]; then
            echo "Can not find ninja/ninja-build/make.";
            exit 2;
        fi
    fi
fi

echo "$NINJA_BIN";

echo "====================================================================================";
echo "=== CMAKE_HOME        = $CMAKE_HOME";
echo "=== ANDROID_NDK       = $ANDROID_NDK";
echo "=== ARCH              = $ARCH";
echo "=== USE_NINJA         = $USE_NINJA";
echo "=== NINJA_BIN         = $NINJA_BIN";
echo "=== ANDROID_STL       = $ANDROID_STL";
echo "=== ANDROID_ABI       = $ARCH";
echo "=== ANDROID_TOOLCHAIN = $ANDROID_TOOLCHAIN";
echo "=== ANDROID_PLATFORM  = android-$ANDROID_MIN_SDK_VERSION";
echo "====================================================================================";

if [ ! -e "$ANDROID_NDK/build/cmake/android.toolchain.cmake" ]; then
    echo "ANDROID_NDK($ANDROID_NDK) is invalid, please check the configure.";
    exit 3;
fi

mkdir -p "$BUILD_ROOT_PREFIX/$SYSTEM_NAME";

cd "$BUILD_ROOT_PREFIX/$SYSTEM_NAME";

if [ $? -ne 0 ]; then
    echo "cd \"$BUILD_ROOT_PREFIX/$SYSTEM_NAME\" failed";
    exit 3;
fi

if [ -e "/bin/bash" ] || [ -e "/usr/bin/bash" ]; then
    PROJECT_ATFRAME_BUILD_THIRD_PARTY_BUSYBOX_MODE="OFF";
else
    PROJECT_ATFRAME_BUILD_THIRD_PARTY_BUSYBOX_MODE="ON";
fi

# cmake
"$CMAKE_BIN" "$SCRIPT_DIR/../.." -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PWD/Output"            \
        -G "$CMAKE_GENERATOR" -DPROJECT_ATFRAME_BUILD_THIRD_PARTY=ON                                        \
        -DPROJECT_ATFRAME_BUILD_THIRD_PARTY_BUSYBOX_MODE=$PROJECT_ATFRAME_BUILD_THIRD_PARTY_BUSYBOX_MODE    \
        -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake"                           \
        -DANDROID_PLATFORM=android-$ANDROID_MIN_SDK_VERSION                                                 \
        -DANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN -DANDROID_ABI=$ARCH -DANDROID_STL=$ANDROID_STL               \
        -DANDROID_PIE=YES "$@";

if [ $? -eq 0 ]; then
    "$CMAKE_BIN" --build . ;
fi
