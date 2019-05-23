#!/bin/bash

cd "$(dirname "$0")"

UNREAL_SYSNAME=$(uname -s);
if [ "$UNREAL_SYSNAME" == "Darwin" ]; then
    UNREAL_SYSNAME="Mac";
fi

export ARCH="x86_64";
SYSTEM_NAME="$(uname -s)-$ARCH";

if [ "$UNREAL_SYSNAME" == "Linux" ]; then
    UNREAL_TOOLCHAIN_NAME="x86_64-unknown-linux-gnu";
    UNREAL_TOOLCHAIN_PREFIX="$UNREAL_SYSNAME/$UNREAL_TOOLCHAIN_NAME";
elif [ "$UNREAL_SYSNAME" == "Mac" ]; then
    UNREAL_TOOLCHAIN_NAME="";
    UNREAL_TOOLCHAIN_PREFIX="$UNREAL_SYSNAME";
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

if [ "$UNREAL_SYSNAME" == "Linux" ]; then
    if [ -z "$UNREAL_LLVM_DIR" ]; then
        UNREAL_LLVM_DIR="$(find "$UNREAL_ENGINE_ROOT/Engine/Extras/ThirdPartyNotUE/SDKs/Host$UNREAL_SYSNAME/${UNREAL_SYSNAME}_x64" -name clang | grep $UNREAL_TOOLCHAIN_NAME | grep bin | grep -v grep)";
        if [ -z "$UNREAL_LLVM_DIR" ]; then
            echo "UNREAL_LLVM_DIR not found ,please input the UNREAL_LLVM_DIR(which contains bin/clang) and then press ENTER.";
            read -r -p "UNREAL_LLVM_DIR: " UNREAL_LLVM_DIR;
            UNREAL_LLVM_DIR="${UNREAL_LLVM_DIR//\\/\/}";
        else
            UNREAL_LLVM_DIR="$(cd "$(dirname "$UNREAL_LLVM_DIR")/../" && pwd)"
        fi
    fi

    if [ -z "$UNREAL_LIBCXX_DIR" ]; then
        if [ -e "$UNREAL_ENGINE_ROOT/Engine/Source/ThirdParty/$UNREAL_SYSNAME/LibCxx" ]; then
            UNREAL_LIBCXX_DIR="$UNREAL_ENGINE_ROOT/Engine/Source/ThirdParty/$UNREAL_SYSNAME/LibCxx";
            echo "UNREAL_LIBCXX_DIR found, using $UNREAL_LIBCXX_DIR";
        else
            echo "UNREAL_LIBCXX_DIR not found ,please input the UNREAL_LIBCXX_DIR(which contains include/c++/v1 and lib) and then press ENTER(left it empty to use libstdc++).";
            read -r -p "UNREAL_LIBCXX_DIR: " UNREAL_LIBCXX_DIR;
            UNREAL_LIBCXX_DIR="${UNREAL_LIBCXX_DIR//\\/\/}";
        fi
    fi

    if [ ! -z "$UNREAL_LLVM_DIR" ] && [ -e "$UNREAL_LLVM_DIR/bin/clang" ]; then
        export CC="$UNREAL_LLVM_DIR/bin/clang";
        export CXX="$UNREAL_LLVM_DIR/bin/clang++";
        export AR="$UNREAL_LLVM_DIR/bin/llvm-ar";
        export LD="$UNREAL_LLVM_DIR/bin/ld.lld";
        export PATH="$UNREAL_LLVM_DIR/bin:$PATH";
        UNREAL_LLVM_RANLIB=($(find "$UNREAL_LLVM_DIR" -name '*ranlib' | grep bin | grep -v grep));
        if [ ${#UNREAL_LLVM_RANLIB[@]} -gt 0 ]; then
            UNREAL_LLVM_RANLIB="${UNREAL_LLVM_RANLIB[0]}";
            UNREAL_LLVM_RANLIB_CMAKE="-DCMAKE_RANLIB=$UNREAL_LLVM_RANLIB";
        fi

        if [ ! -z "$UNREAL_LIBCXX_DIR" ] && [ -e "$UNREAL_LIBCXX_DIR/include/c++/v1" ]; then
            export LDFLAGS="-L$UNREAL_LIBCXX_DIR/lib/$UNREAL_TOOLCHAIN_PREFIX -lc++ -lc++abi -lpthread"
            export CXXFLAGS="-I$UNREAL_LIBCXX_DIR/include/ -I$UNREAL_LIBCXX_DIR/include/c++/v1 -stdlib=libc++"
        fi
    fi
fi

# copy ThirdParty ...
mkdir -p "$PWD/$SYSTEM_NAME/UE4/include";
mkdir -p "$PWD/$SYSTEM_NAME/UE4/lib";

# UE OpenSSL
UNREAL_OPENSSL_LIBS_DIR=($(ls -t $(find "$UNREAL_ENGINE_ROOT/Engine/Source/ThirdParty/OpenSSL" -iregex ".*$UNREAL_TOOLCHAIN_PREFIX/libssl.a")));
if [ ${#UNREAL_OPENSSL_LIBS_DIR[@]} -gt 0 ]; then
    UNREAL_OPENSSL_LIBS_DIR="$(cd "$(dirname ${UNREAL_OPENSSL_LIBS_DIR[0]})" && pwd)";
    UNREAL_OPENSSL_INC_DIR="$(echo "$UNREAL_OPENSSL_LIBS_DIR" | sed 's/\(.*\)lib/\1include/')";

    cp -rf "$UNREAL_OPENSSL_INC_DIR"/* "$PWD/$SYSTEM_NAME/UE4/include/";
    cp -rf "$UNREAL_OPENSSL_LIBS_DIR"/* "$PWD/$SYSTEM_NAME/UE4/lib/";
    UNREAL_OPENSSL_CMAKE="-DOPENSSL_ROOT_DIR=$PWD/$SYSTEM_NAME/UE4";
fi

# UE curl
UNREAL_LIBCURL_LIBS_DIR=($(ls -t $(find "$UNREAL_ENGINE_ROOT/Engine/Source/ThirdParty/libcurl" -iregex ".*$UNREAL_TOOLCHAIN_PREFIX/libcurl.a")));
if  [ ${#UNREAL_LIBCURL_LIBS_DIR[@]} -gt 0 ]; then
    UNREAL_LIBCURL_LIBS_DIR="$(cd "$(dirname ${UNREAL_LIBCURL_LIBS_DIR[0]})" && pwd)";
    UNREAL_LIBCURL_INC_DIR="$(echo "$UNREAL_LIBCURL_LIBS_DIR" | sed 's/\(.*\)lib/\1include/')";
    cp -rf "$UNREAL_LIBCURL_INC_DIR"/* "$PWD/$SYSTEM_NAME/UE4/include/";
    cp -rf "$UNREAL_LIBCURL_LIBS_DIR"/* "$PWD/$SYSTEM_NAME/UE4/lib/";
    UNREAL_LIBCURL_CMAKE="-DCURL_ROOT=$PWD/$SYSTEM_NAME/UE4";
fi

chmod +x ./GenerateUnix-x64.sh;

./GenerateUnix-x64.sh           \
    $UNREAL_LIBCURL_CMAKE       \
    $UNREAL_OPENSSL_CMAKE       \
    $UNREAL_LLVM_RANLIB_CMAKE
