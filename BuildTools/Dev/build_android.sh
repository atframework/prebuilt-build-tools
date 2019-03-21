#!/bin/bash

#
###########################################################################
#
# Don't change anything here
WORKING_DIR="$PWD";

ARCHS="x86 x86_64 armeabi-v7a arm64-v8a";
NDK_ROOT=$NDK_ROOT;
SOURCE_DIR="$(dirname "$0")/../../";
CONF_ANDROID_NATIVE_API_LEVEL=21 ;
ANDROID_TOOLCHAIN=clang ;
ANDROID_STL=c++_static ; #
MBEDTLS_ROOT="" ;
OPENSSL_ROOT="" ;
BUILD_TYPE="RelWithDebInfo" ;
# OTHER_CFLAGS="-fPIC" ; # Android使用-DANDROID_PIE=YES
OTHER_LD_FLAGS="-llog";  # protobuf依赖liblog.so

# ======================= options ======================= 
while getopts "a:b:c:n:hl:m:o:r:t:-" OPTION; do
    case $OPTION in
        a)
            ARCHS="$OPTARG";
        ;;
        b)
            BUILD_TYPE="$OPTARG";
        ;;
        c)
            ANDROID_STL="$OPTARG";
        ;;
        n)
            NDK_ROOT="$OPTARG";
        ;;
        h)
            echo "usage: $0 [options] -n NDK_ROOT -r SOURCE_DIR [-- [cmake options]]";
            echo "options:";
            echo "-a [archs]                    which arch need to built, multiple values must be split by space(default: $ARCHS)";
            echo "-b [build type]               build type(default: $BUILD_TYPE, available: Debug, Release, RelWithDebInfo, MinSizeRel)";
            echo "-c [android stl]              stl used by ndk(default: $ANDROID_STL, available: system, stlport_static, stlport_shared, gnustl_static, gnustl_shared, c++_static, c++_shared, none)";
            echo "-n [ndk root directory]       ndk root directory.(default: $DEVELOPER_ROOT)";
            echo "-l [api level]                API level, see $NDK_ROOT/platforms for detail.(default: $CONF_ANDROID_NATIVE_API_LEVEL)";
            echo "-r [source dir]               root directory of this library";
            echo "-t [toolchain]                ANDROID_TOOLCHAIN.(gcc version/clang, default: $ANDROID_TOOLCHAIN, @see CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION in cmake)";
            echo "-o [openssl root directory]   openssl root directory, which has [$ARCHS]/include and [$ARCHS]/lib";
            echo "-m [mbedtls root directory]   mbedtls root directory, which has [$ARCHS]/include and [$ARCHS]/lib";
            echo "-h                            help message.";
            exit 0;
        ;;
        r)
            SOURCE_DIR="$OPTARG";
        ;;
        t)
            ANDROID_TOOLCHAIN="$OPTARG";
        ;;
        l)
            CONF_ANDROID_NATIVE_API_LEVEL=$OPTARG;
        ;;
        o)
            OPENSSL_ROOT="$OPTARG";
        ;;
        m)
            MBEDTLS_ROOT="$OPTARG";
        ;;
        -) 
            break;
            break;
        ;;
        ?)  #当有不认识的选项的时候arg为?
            echo "unkonw argument detected";
            exit 1;
        ;;
    esac
done

shift $(($OPTIND-1));

##########
if [ ! -e "$SOURCE_DIR/CMakeLists.txt" ]; then
    echo "$SOURCE_DIR/CMakeLists.txt not found";
    exit -2;
fi
SOURCE_DIR="$(readlink -f "$SOURCE_DIR")";

CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=$ANDROID_TOOLCHAIN;
if [ "${ANDROID_TOOLCHAIN:0:5}" != "clang" ]; then
    ANDROID_TOOLCHAIN="gcc";
fi

for ARCH in ${ARCHS}; do
    echo "================== Compling $ARCH ==================";
    echo "Building $(basename $0) for android-$CONF_ANDROID_NATIVE_API_LEVEL ${ARCH}"
    
    # sed -i.bak '4d' Makefile;
    echo "Please stand by..."
    if [ -e "$WORKING_DIR/build-for-android/$ARCH" ]; then
        rm -rf "$WORKING_DIR/build-for-android/$ARCH";
    fi
    mkdir -p "$WORKING_DIR/build-for-android/$ARCH";
    cd "$WORKING_DIR/build-for-android/$ARCH";
    
    INSTALL_PREFIX_DIR="$WORKING_DIR/build-for-android/install-prefix/$ARCH";

    if [ -e "$INSTALL_PREFIX_DIR" ]; then
        rm -rf $INSTALL_PREFIX_DIR;
    fi

    EXT_OPTIONS="";
    if [ ! -z "$OPENSSL_ROOT" ] && [ -e "$OPENSSL_ROOT" ]; then
        EXT_OPTIONS="$EXT_OPTIONS -DCRYPTO_USE_OPENSSL=YES -DOPENSSL_ROOT_DIR=$OPENSSL_ROOT/$ARCH";
    fi
    if [ ! -z "$MBEDTLS_ROOT" ] && [ -e "$MBEDTLS_ROOT" ]; then
        EXT_OPTIONS="$EXT_OPTIONS -DCRYPTO_USE_MBEDTLS=YES -DMBEDTLS_ROOT=$MBEDTLS_ROOT/$ARCH";
    fi

    # 64 bits must at least using android-21
    # @see $NDK_ROOT/build/cmake/android.toolchain.cmake
    echo $ARCH | grep -E '64(-v8a)?$' ;
    if [ $? -eq 0 ] && [ $CONF_ANDROID_NATIVE_API_LEVEL -lt 21 ]; then
        ANDROID_NATIVE_API_LEVEL=21 ;
    else
        ANDROID_NATIVE_API_LEVEL=$CONF_ANDROID_NATIVE_API_LEVEL ;
    fi
    
    # add -DCMAKE_OSX_DEPLOYMENT_TARGET=7.1 to specify the min SDK version
    # remove -DANDROID_NDK="$NDK_ROOT" to avoid warning message
    cmake "$SOURCE_DIR" -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX_DIR" \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_ROOT/build/cmake/android.toolchain.cmake" \
        -DCMAKE_ANDROID_NDK="$NDK_ROOT" \
        -DANDROID_PLATFORM=android-$ANDROID_NATIVE_API_LEVEL -DCMAKE_ANDROID_API=$ANDROID_NATIVE_API_LEVEL \
        -DANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN -DCMAKE_ANDROID_NDK_TOOLCHAIN_VERSION=$CMAKE_ANDROID_NDK_TOOLCHAIN_VERSION \
        -DANDROID_ABI=$ARCH -DCMAKE_ANDROID_ARCH_ABI=$ARCH \
        -DANDROID_STL=$ANDROID_STL -DCMAKE_ANDROID_STL_TYPE=$ANDROID_STL \
        -DANDROID_PIE=YES -DCMAKE_SHARED_LINKER_FLAGS="$OTHER_LD_FLAGS" -DCMAKE_EXE_LINKER_FLAGS="$OTHER_LD_FLAGS" $EXT_OPTIONS "$@";
    if [ $? -ne 0 ]; then
        echo "cmake configure failed"
        exit 1
    fi
    
    cmake --build . -- -j4 ;
    if [ $? -ne 0 ]; then
        echo "cmake build failed"
        exit 1
    fi

    cmake --build . --target install ;
done

echo "Building done.";
