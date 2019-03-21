#!/bin/bash

# JAVA_HOME
# ANDROID_NDK
# ANDROID_SDK
# CMAKE_HOME
# PACKAGE_NAME

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)";
SCRIPT_DIR="${SCRIPT_DIR//\\//}";
source "$SCRIPT_DIR/AndroidSetting.sh";

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

if [ ! -e "$CMAKE_HOME/bin/cmake" ] && [ ! -e "$CMAKE_HOME/bin/cmake.exe" ]; then
    echo "Can not find cmake in $CMAKE_HOME, exit now.";
    exit 1;
fi

export CMAKE_HOME ;

# jdk
if [ -z "$JAVA_HOME" ]; then
    JAVAC_BIN="$(which javac 2>&1)";
    if [ $? -eq 0 ]; then
        JAVA_HOME="$(dirname "$(dirname "$JAVAC_BIN")")";
        echo "JAVA_HOME is not set, we try to use JAVA_HOME=$JAVA_HOME";
    else
        echo "Executable javac not found ,please input the JAVA_HOME(which contains bin/javac) and then press ENTER.";
        read -r -p "JAVA_HOME: " JAVA_HOME;
        JAVA_HOME="${JAVA_HOME//\\/\/}";
    fi
fi

export JAVA_HOME ;

# android sdk
if [  -z "$ANDROID_SDK" ]; then
    echo "ANDROID_SDK is not set ,please input the ANDROID_SDK(which contains platform-tools) and then press ENTER.";
    read -r -p "ANDROID_SDK: " ANDROID_SDK;
    ANDROID_SDK="${ANDROID_SDK//\\/\/}";
fi

export ANDROID_SDK ;

# android ndk
if [ -z "$ANDROID_NDK" ]; then
    echo "ANDROID_NDK is not set ,please input the ANDROID_NDK(which contains build/cmake/android.toolchain.cmake) and then press ENTER.";
    read -r -p "ANDROID_NDK: " ANDROID_NDK;
    ANDROID_NDK="${ANDROID_NDK//\\/\/}";
fi

export ANDROID_NDK ;

# package name
if [ ! -z "$PACKAGE_NAME" ]; then
    echo "PACKAGE_NAME is not set ,please input the PACKAGE_NAME(default: org.atframework.prebuiltbuildtools) and then press ENTER.";
    read -r -p "PACKAGE_NAME: " PACKAGE_NAME;
fi

PACKAGE_NAME=$PACKAGE_NAME;

if [ -z "$PACKAGE_NAME" ]; then
    PACKAGE_NAME="org.atframework.prebuiltbuildtools";
fi

PACKAGE_NANESPACE=${PACKAGE_NAME%.*};
APP_NAME=${PACKAGE_NAME##*.};

SYSTEM_NAME="AndroidBuildOn$(uname -s)";

echo "====================================================================================";
echo "=== CMAKE_HOME    = $CMAKE_HOME";
echo "=== JAVA_HOME     = $JAVA_HOME";
echo "=== ANDROID_SDK   = $ANDROID_SDK";
echo "=== ANDROID_NDK   = $ANDROID_NDK";
echo "=== PACKAGE_NAME  = $PACKAGE_NAME";
echo "====================================================================================";

TRY_TO_FIND_ADB_BIN=$(find "$ANDROID_SDK/platform-tools" -type f -name "adb*");
if [ -z "$TRY_TO_FIND_ADB_BIN" ]; then
    echo "ANDROID_SDK($ANDROID_SDK) is invalid, please check the configure.";
    exit 2;
fi

if [ ! -e "$ANDROID_NDK/build/cmake/android.toolchain.cmake" ]; then
    echo "ANDROID_NDK($ANDROID_NDK) is invalid, please check the configure.";
    exit 2;
fi

if [ -z "$BUILD_ROOT_PREFIX" ]; then
    BUILD_ROOT_PREFIX="$SCRIPT_DIR";
fi

mkdir -p "$BUILD_ROOT_PREFIX/$SYSTEM_NAME";

cd "$BUILD_ROOT_PREFIX/$SYSTEM_NAME";

if [ $? -ne 0 ]; then
    echo "cd \"$BUILD_ROOT_PREFIX/$SYSTEM_NAME\" failed";
    exit 3;
fi

cp -rf "$SCRIPT_DIR/../Platform/Android"/* ./ ;

rm -rf app/src/main/cpp ;

for ANDROID_ARCH in $ANDROID_ARCHS; do
    if [ -z "$ANDROID_ARCHS_ABI_FILTER"]; then
        ANDROID_ARCHS_ABI_FILTER="\"$ANDROID_ARCH\"";
    else
        ANDROID_ARCHS_ABI_FILTER="$ANDROID_ARCHS_ABI_FILTER, \"$ANDROID_ARCH\"";
    fi
done

sed -i -r "s/applicationId\\s*[\"\\'][^\"\\']*[\"\\']/applicationId \"$PACKAGE_NANESPACE\"/" "app/build.gradle" ;
sed -i -r "s/package\\s*=\\s*[\"\\'][^\"\\']*[\"\\']/package=\"$PACKAGE_NANESPACE\"/" "app/src/main/AndroidManifest.xml" ;
sed -i -r "s;<string\\s*name\\s*=\\s*[\"\\']app_name[\"\\']\\s*>[^>]*>;<string name=\"app_name\">$APP_NAME</string>;" "app/src/main/res/values/strings.xml";
sed -i -r "s;path\\s*[\"\\'][^\"\\']*CMakeLists.txt[\"\\'];path \"$SCRIPT_DIR/../CMakeLists.txt\";" "app/build.gradle" ;
sed -i -r "s;compileSdkVersion\\s*[0-9]*;compileSdkVersion $ANDROID_COMPILE_SDK_VERSION;" "app/build.gradle" ;
sed -i -r "s;minSdkVersion\\s*[0-9]*;minSdkVersion $ANDROID_MIN_SDK_VERSION;" "app/build.gradle" ;
sed -i -r "s;targetSdkVersion\\s*[0-9]*;targetSdkVersion $ANDROID_TARGET_SDK_VERSION;" "app/build.gradle" ;
sed -i -r "s;abiFilters\\s*[\"\\'][^\"\\']*[\"\\'];abiFilters $ANDROID_ARCHS_ABI_FILTER;" "app/build.gradle" ;
sed -i -r "s;[\"\\']-DANDROID_TOOLCHAIN=[^\"\\']*[\"\\'];\"-DANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN\";" "app/build.gradle" ;
sed -i -r "s;[\"\\']-DANDROID_STL=[^\"\\']*[\"\\'];\"-DANDROID_STL=$ANDROID_STL\";" "app/build.gradle" ;
sed -i -r "s;[\"\\']-DANDROID_CPP_FEATURES=[^\"\\']*[\"\\'];\"-DANDROID_CPP_FEATURES=$ANDROID_CPP_FEATURES\";" "app/build.gradle" ;

function convert_to_gradle_conf() {
    RET="$1";
    RET="${RET//:/\\:}";
    RET="${RET// /\\ }";
    echo "$RET";
}

ANDROID_NDK_GRADLE_CONF="$(convert_to_gradle_conf "$ANDROID_NDK")";
ANDROID_SDK_GRADLE_CONF="$(convert_to_gradle_conf "$ANDROID_SDK")";
CMAKE_HOME_GRADLE_CONF="$(convert_to_gradle_conf "$CMAKE_HOME")";

echo "## This file must *NOT* be checked into Version Control Systems,
# as it contains information specific to your local configuration.
#
# Location of the SDK. This is only used by Gradle.
# For customization when using a Version Control System, please read the
# header note.
# Generated at $(date +'%Y-%m-%d %H:%M:%S')
ndk.dir=$ANDROID_NDK_GRADLE_CONF
sdk.dir=$ANDROID_SDK_GRADLE_CONF
cmake.dir=$CMAKE_HOME_GRADLE_CONF
" > "local.properties" ;

set | grep WINDIR ;


if [  $? -eq 0 ]  ; then
    ./gradlew.bat build --info ;
else
    chmod +x ./gradlew;
    ./gradlew build --info ;
fi

