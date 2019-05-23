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
    UNREAL_SYSNAME="Mac";
fi

source "$SCRIPT_DIR/LoadMacEnvs.sh";

SYSTEM_NAME_ANY="Mac" ;

# copy ThirdParty ...
mkdir -p "$PWD/$SYSTEM_NAME_ANY/UE4/include";
mkdir -p "$PWD/$SYSTEM_NAME_ANY/UE4/lib";

# UE OpenSSL
UNREAL_OPENSSL_LIBS_DIR=($(ls -t $(find "$UNREAL_ENGINE_ROOT/Engine/Source/ThirdParty/OpenSSL" -iregex ".*$SYSTEM_NAME_ANY/libssl.a")));
UNREAL_OPENSSL_CMAKE="";
if [ ${#UNREAL_OPENSSL_LIBS_DIR[@]} -gt 0 ]; then
    for UNREAL_OPENSSL_FOUND in ${UNREAL_OPENSSL_LIBS_DIR[@]} ; do
        if [ ! -z "$UNREAL_OPENSSL_CMAKE" ]; then
            break ;
        fi
        UNREAL_OPENSSL_LIBS_DIR="$(cd "$(dirname "$UNREAL_OPENSSL_FOUND")" && pwd)";
        UNREAL_OPENSSL_INC_DIR="$(echo "$UNREAL_OPENSSL_LIBS_DIR" | sed 's/\(.*\)lib/\1include/')";

        if [ ! -e "$UNREAL_OPENSSL_LIBS_DIR" ] || [ ! -e "$UNREAL_OPENSSL_INC_DIR" ] ; then
            continue ;
        fi

        echo "copy $UNREAL_OPENSSL_INC_DIR/* to $PWD/$SYSTEM_NAME_ANY/UE4/include/" ;
        cp -rf "$UNREAL_OPENSSL_INC_DIR"/* "$PWD/$SYSTEM_NAME_ANY/UE4/include/";
        echo "copy $UNREAL_OPENSSL_LIBS_DIR/* to $PWD/$SYSTEM_NAME_ANY/UE4/lib/" ;
        cp -rf "$UNREAL_OPENSSL_LIBS_DIR"/* "$PWD/$SYSTEM_NAME_ANY/UE4/lib/";
        UNREAL_OPENSSL_CMAKE="-DOPENSSL_ROOT_DIR=$PWD/$SYSTEM_NAME_ANY/UE4";
    done
fi

# UE curl
UNREAL_LIBCURL_LIBS_DIR=($(ls -t $(find "$UNREAL_ENGINE_ROOT/Engine/Source/ThirdParty/libcurl" -iregex ".*$SYSTEM_NAME_ANY/libcurl.a")));
UNREAL_LIBCURL_CMAKE="";
if  [ ${#UNREAL_LIBCURL_LIBS_DIR[@]} -gt 0 ]; then
    for UNREAL_LIBCURL_FOUND in ${UNREAL_LIBCURL_LIBS_DIR[@]} ; do
        if [ ! -z "$UNREAL_LIBCURL_CMAKE" ]; then
            break ;
        fi
        UNREAL_LIBCURL_LIBS_DIR="$(cd "$(dirname "$UNREAL_LIBCURL_FOUND")" && pwd)";
        UNREAL_LIBCURL_INC_DIR="$(echo "$UNREAL_LIBCURL_LIBS_DIR" | sed 's/\(.*\)lib/\1include/')";

        if [ ! -e "$UNREAL_LIBCURL_LIBS_DIR" ] || [ ! -e "$UNREAL_LIBCURL_INC_DIR" ] ; then
            continue ;
        fi

        echo "copy $UNREAL_LIBCURL_INC_DIR/* to $PWD/$SYSTEM_NAME_ANY/UE4/include/";
        cp -rf "$UNREAL_LIBCURL_INC_DIR"/* "$PWD/$SYSTEM_NAME_ANY/UE4/include/";
        echo "copy $UNREAL_LIBCURL_LIBS_DIR/* to $PWD/$SYSTEM_NAME_ANY/UE4/lib/"
        cp -rf "$UNREAL_LIBCURL_LIBS_DIR"/* "$PWD/$SYSTEM_NAME_ANY/UE4/lib/";
        UNREAL_LIBCURL_CMAKE="-DCURL_ROOT=$PWD/$SYSTEM_NAME_ANY/UE4";
    done
fi

if [ "x$MAC_BITCODE" != "x" ]; then
    UNREAL_MAC_CFLAGS="$UNREAL_MAC_CFLAGS -fembed-bitcode=$MAC_BITCODE";
fi

LAST_SUCCESS_ARCH="";

for ARCH in $MAC_ARCHS; do
    export ARCH=$ARCH ;
    export SYSTEM_NAME="$SYSTEM_NAME_ANY-$ARCH" ;

    if [[ "${ARCH}" == "i386" || "${ARCH}" == "x86_64" ]]; then
        if [ -e "${DEVELOPER_ROOT}/Platforms/iPhoneSimulator.platform" ]; then
            PLATFORM="iPhoneSimulator" ;
        else
            PLATFORM="MacOSX" ;
        fi
    else
        PLATFORM="iPhoneOS" ;
    fi

    export DEVROOT="${DEVELOPER_ROOT}/Platforms/${PLATFORM}.platform/Developer"
    if [ -e "${DEVROOT}/SDKs/${PLATFORM}${SDKVERSION}.sdk" ]; then
        export SDKROOT="${DEVROOT}/SDKs/${PLATFORM}${SDKVERSION}.sdk"
    else
        export SDKROOT="${DEVROOT}/SDKs/${PLATFORM}.sdk"
    fi
    export BUILD_TOOLS="${DEVELOPER_ROOT}"

    echo "====================================================================================";
    echo "=== CMAKE_OSX_SYSROOT=$SDKROOT";
    echo "=== CMAKE_OSX_ARCHITECTURES=$ARCH";
    echo "=== CMAKE_SYSROOT=$SDKROOT";
    echo "------------------------------------------------------------------------------------";
    echo "=== $UNREAL_LIBCURL_CMAKE";
    echo "=== $UNREAL_OPENSSL_CMAKE";
    echo "====================================================================================";


    chmod +x "$SCRIPT_DIR/GenerateUnixGo.sh" ;
    "$SCRIPT_DIR/GenerateUnixGo.sh"             \
            "-DCMAKE_OSX_SYSROOT=$SDKROOT"      \
            "-DCMAKE_OSX_ARCHITECTURES=$ARCH"   \
            "-DCMAKE_SYSROOT=$SDKROOT"          \
            "-DCMAKE_C_FLAGS=$OTHER_CFLAGS"     \
            "-DCMAKE_CXX_FLAGS=$OTHER_CFLAGS"   \
            $UNREAL_LIBCURL_CMAKE               \
            $UNREAL_OPENSSL_CMAKE               \
            "$@"


    LAST_EXIT_CODE=$?;
    if [ $LAST_EXIT_CODE -ne 0 ]; then
        exit $LAST_EXIT_CODE;
    fi

    LAST_SUCCESS_ARCH="$ARCH";
done

# echo "Linking and packaging library...";
# lipo -create $(find "$WORKING_DIR/install" -name $LIB_NAME.a) -output "$WORKING_DIR/lib/$LIB_NAME.a";
which lipo > /dev/null 2>&1 ;
if [ $? -eq 0 ]; then
    PREBUILT_OUTPUT_DIR="$(cd "$SCRIPT_DIR/../../ThirdParty" && pwd)";
    # PREBUILT_OUTPUT_DIR="$(cd "$PWD/../../ThirdParty" && pwd)";
    cd "$PREBUILT_OUTPUT_DIR";

    for LIBPREBUILTPATH in * ; do
        if [ ! -e "$LIBPREBUILTPATH/Prebuilt" ]; then
            continue;
        fi
        find "$LIBPREBUILTPATH/Prebuilt" -iname "Darwin-*" > /dev/null 2>&1 ;
        if [ $? -ne 0 ]; then
            continue;
        fi

        LIBNAMES=$(find "$LIBPREBUILTPATH/Prebuilt" -iregex ".*Darwin.*/lib.*/.*\\.a" | awk -F '\/' '{print $NF}' | sort | uniq);
        for LIBPATH in ${LIBNAMES[@]} ; do
            LIBNAME="$(basename "$LIBPATH")";
            # SYSTEM_NAME_ANY
            mkdir -p "$LIBPREBUILTPATH/Prebuilt/$SYSTEM_NAME_ANY/lib" ;
            find "$LIBPREBUILTPATH/Prebuilt" -iregex ".*Darwin.*/lib.*/$LIBNAME" | xargs lipo -create -output "$LIBPREBUILTPATH/Prebuilt/$SYSTEM_NAME_ANY/lib/$LIBNAME" ;
            find "$LIBPREBUILTPATH/Prebuilt" -iregex ".*Darwin.*/lib.*/$LIBNAME" | xargs echo "$LIBPREBUILTPATH/Prebuilt/$SYSTEM_NAME_ANY/lib/$LIBNAME :" ;
        done

        SELECT_COPY_DIR="";
        SELECT_COPY_DIR_FALLBACK="";
        for COPY_DIR in $(find "$LIBPREBUILTPATH/Prebuilt" -iregex ".*Darwin.*" -depth 1) ; do
            if [ ! -z "$SELECT_COPY_DIR" ]; then
                break ;
            fi

            if [ -e "$COPY_DIR/include" ]; then
                SELECT_COPY_DIR="$COPY_DIR";
            else
                SELECT_COPY_DIR_FALLBACK="$COPY_DIR";
            fi
        done
        if [ -z "$SELECT_COPY_DIR" ]; then
            SELECT_COPY_DIR="$SELECT_COPY_DIR_FALLBACK" ;
        fi

        if [ -e "$SELECT_COPY_DIR/include" ]; then
            mkdir -p "$LIBPREBUILTPATH/Prebuilt/$SYSTEM_NAME_ANY" ;
            echo "copy $SELECT_COPY_DIR/include to $LIBPREBUILTPATH/Prebuilt/$SYSTEM_NAME_ANY/ ..." ;
            cp -rf "$SELECT_COPY_DIR/include" "$LIBPREBUILTPATH/Prebuilt/$SYSTEM_NAME_ANY/" ;
        elif [ -e "$SELECT_COPY_DIR" ]; then
            mkdir -p "$LIBPREBUILTPATH/Prebuilt/$SYSTEM_NAME_ANY" ;
            for LIB_COPY_NAME in "$SELECT_COPY_DIR"/* ; do
                LIB_COPY_BASENAME="$(basename "$LIB_COPY_NAME")";
                if [ "$LIB_COPY_BASENAME" != "lib" ] && [ "$LIB_COPY_BASENAME" != "lib64" ]; then
                    echo "copy $LIB_COPY_NAME to $LIBPREBUILTPATH/Prebuilt/$SYSTEM_NAME_ANY/ ..." ;
                    cp -rf "$LIB_COPY_NAME" "$LIBPREBUILTPATH/Prebuilt/$SYSTEM_NAME_ANY/" ;
                fi
            done
        else
            echo -e "\033[33;1m--- \033[31;1m$LIBPREBUILTPATH\033[33;1m : $LIBPREBUILTPATH/Prebuilt/Darwin-* not found, skip copy include dir\033[0m" ;
        fi

        echo -e "\033[32;1m=== Package \033[31;1m$LIBPREBUILTPATH\033[32;1m done ===\033[0m" ;
    done

    cd - ;
fi
