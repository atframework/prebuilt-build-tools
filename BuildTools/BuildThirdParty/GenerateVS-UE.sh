#!/bin/bash

cd "$(dirname "$0")"

if [ -z "$UNREAL_SYSNAME" ]; then
    UNREAL_SYSNAME="Win64";
fi

if [ -z "$SYSTEM_NAME" ]; then
    echo "SYSTEM_NAME is required";
    exit 1;
fi

if [ -z "$UNREAL_ENGINE_ROOT" ]; then
    echo "UNREAL_ENGINE_ROOT not found ,please input the UNREAL_ENGINE_ROOT(which contains Engine/Source) and then press ENTER.";
    read -r -p "UNREAL_ENGINE_ROOT: " UNREAL_ENGINE_ROOT;
    UNREAL_ENGINE_ROOT="${UNREAL_ENGINE_ROOT//\\/\/}";
fi

if [ -z "$UNREAL_ENGINE_ROOT" ] || [ ! -e "$UNREAL_ENGINE_ROOT/Engine/Source" ]; then
    echo "UNREAL_ENGINE_ROOT($UNREAL_ENGINE_ROOT) is invalid. exit now.";
    exit 1;
fi

# copy ThirdParty ...
mkdir -p "$PWD/$SYSTEM_NAME/UE4/include";
mkdir -p "$PWD/$SYSTEM_NAME/UE4/lib";

# UE OpenSSL
for DIR in $(ls -t $(find "$UNREAL_ENGINE_ROOT/Engine/Source/ThirdParty/OpenSSL" -regex ".*$UNREAL_SYSNAME.*/ssleay32.lib")); do
    UNREAL_OPENSSL_LIBS_DIR="$DIR";
    break;
done
if [ ! -z "$UNREAL_OPENSSL_LIBS_DIR" ]; then
    UNREAL_OPENSSL_LIBS_DIR="$(cd "$(dirname $UNREAL_OPENSSL_LIBS_DIR)" && pwd)";
    UNREAL_OPENSSL_INC_DIR="$(echo "$UNREAL_OPENSSL_LIBS_DIR" | sed 's/\(.*\)lib/\1include/')";

    cp -rf "$UNREAL_OPENSSL_INC_DIR"/* "$PWD/$SYSTEM_NAME/UE4/include/";
    cp -rf "$UNREAL_OPENSSL_LIBS_DIR"/* "$PWD/$SYSTEM_NAME/UE4/lib/";
    UNREAL_OPENSSL_CMAKE="-DOPENSSL_ROOT_DIR=$PWD/$SYSTEM_NAME/UE4";
fi

# UE curl
for DIR in $(ls -t $(find "$UNREAL_ENGINE_ROOT/Engine/Source/ThirdParty/libcurl" -regex ".*$UNREAL_SYSNAME.*/libcurl_a.lib")); do
    UNREAL_LIBCURL_LIBS_DIR="$DIR";
    break;
done
if  [ ! -z "$UNREAL_LIBCURL_LIBS_DIR" ]; then
    UNREAL_LIBCURL_LIBS_DIR="$(cd "$(dirname $UNREAL_LIBCURL_LIBS_DIR)" && pwd)";
    UNREAL_LIBCURL_INC_DIR="$(echo "$UNREAL_LIBCURL_LIBS_DIR" | sed 's/\(.*\)lib/\1include/')";
    cp -rf "$UNREAL_LIBCURL_INC_DIR"/* "$PWD/$SYSTEM_NAME/UE4/include/";
    cp -rf "$UNREAL_LIBCURL_LIBS_DIR"/* "$PWD/$SYSTEM_NAME/UE4/lib/";
    UNREAL_LIBCURL_CMAKE="-DCURL_ROOT=$PWD/$SYSTEM_NAME/UE4";
fi

chmod +x ./GenerateVSGo.sh;

./GenerateVSGo.sh               \
    $UNREAL_LIBCURL_CMAKE       \
    $UNREAL_OPENSSL_CMAKE       \
    "$@"
