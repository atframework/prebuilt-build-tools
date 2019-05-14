#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)";
SCRIPT_DIR="${SCRIPT_DIR//\\//}";

if [ -z "$UNREAL_ENGINE_ROOT" ]; then
    echo "UNREAL_ENGINE_ROOT not found ,please input the UNREAL_ENGINE_ROOT(which contains Engine/Source) and then press ENTER.";
    read -r -p "UNREAL_ENGINE_ROOT: " UNREAL_ENGINE_ROOT;
    UNREAL_ENGINE_ROOT="${UNREAL_ENGINE_ROOT//\\/\/}";
fi

if [ -z "$UNREAL_ENGINE_ROOT" ] || [ ! -e "$UNREAL_ENGINE_ROOT/Engine/Source" ]; then
    echo "UNREAL_ENGINE_ROOT($UNREAL_ENGINE_ROOT) is invalid. exit now.";
    exit 1;
fi

if [ -z "$UNREAL_SYSNAME" ]; then
    UNREAL_SYSNAME="Android";
fi

source "$SCRIPT_DIR/LoadAndroidEnvs.sh";

for ARCH in $ANDROID_ARCHS; do
    export SYSTEM_NAME="Android-$ARCH" ;
    export ARCH=$ARCH ;

    if [ "${ARCH:0:7}" == "armeabi"  ]; then
        UNREAL_ARCH="ARMv7";
    elif [ "${ARCH:0:5}" == "arm64"  ]; then
        UNREAL_ARCH="ARM64";
    elif [ "$ARCH" == "x86"  ]; then
        UNREAL_ARCH="x86";
    elif [ "$ARCH" == "x86_64"  ]; then
        UNREAL_ARCH="x64";
    else
        echo "ARCH($ARCH) is unsupport, exit now.";
        exit 2;
    fi

    # copy ThirdParty ...
    mkdir -p "$PWD/$SYSTEM_NAME/UE4/include";
    mkdir -p "$PWD/$SYSTEM_NAME/UE4/lib";

    # UE OpenSSL
    UNREAL_OPENSSL_LIBS_DIR=($(ls -t $(find "$UNREAL_ENGINE_ROOT/Engine/Source/ThirdParty/OpenSSL" -iregex ".*$UNREAL_SYSNAME/$UNREAL_ARCH/libssl.a")));
    if [ ${#UNREAL_OPENSSL_LIBS_DIR[@]} -gt 0 ]; then
        UNREAL_OPENSSL_LIBS_DIR="$(cd "$(dirname ${UNREAL_OPENSSL_LIBS_DIR[0]})" && pwd)";
        UNREAL_OPENSSL_INC_DIR="$(echo "$UNREAL_OPENSSL_LIBS_DIR" | sed 's/\(.*\)lib/\1include/')";

        cp -rf "$UNREAL_OPENSSL_INC_DIR"/* "$PWD/$SYSTEM_NAME/UE4/include/";
        cp -rf "$UNREAL_OPENSSL_LIBS_DIR"/* "$PWD/$SYSTEM_NAME/UE4/lib/";
        UNREAL_OPENSSL_CMAKE="-DOPENSSL_ROOT_DIR=$PWD/$SYSTEM_NAME/UE4";
    fi

    # UE curl
    UNREAL_LIBCURL_LIBS_DIR=($(ls -t $(find "$UNREAL_ENGINE_ROOT/Engine/Source/ThirdParty/libcurl" -iregex ".*$UNREAL_SYSNAME/$UNREAL_ARCH/libcurl.a")));
    if  [ ${#UNREAL_LIBCURL_LIBS_DIR[@]} -gt 0 ]; then
        UNREAL_LIBCURL_LIBS_DIR="$(cd "$(dirname ${UNREAL_LIBCURL_LIBS_DIR[0]})" && pwd)";
        UNREAL_LIBCURL_INC_DIR="$(echo "$UNREAL_LIBCURL_LIBS_DIR" | sed 's/\(.*\)lib/\1include/')";
        cp -rf "$UNREAL_LIBCURL_INC_DIR"/* "$PWD/$SYSTEM_NAME/UE4/include/";
        cp -rf "$UNREAL_LIBCURL_LIBS_DIR"/* "$PWD/$SYSTEM_NAME/UE4/lib/";
        UNREAL_LIBCURL_CMAKE="-DCURL_ROOT=$PWD/$SYSTEM_NAME/UE4";
    fi

    chmod +x "$SCRIPT_DIR/GenerateAndroidGo.sh" ;
    "$SCRIPT_DIR/GenerateAndroidGo.sh"  \
            $UNREAL_LIBCURL_CMAKE       \
            $UNREAL_OPENSSL_CMAKE       \
            $UNREAL_LLVM_RANLIB_CMAKE

    LAST_EXIT_CODE=$?;
    if [ $LAST_EXIT_CODE -ne 0 ]; then
        exit $LAST_EXIT_CODE;
    fi
done
