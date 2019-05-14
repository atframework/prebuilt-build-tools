#!/bin/bash

# CMAKE_HOME
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)";
SCRIPT_DIR="${SCRIPT_DIR//\\//}";

# cmake
printf "Checking cmake ...              ";
if [ -z "$CMAKE_HOME" ]; then
    CMAKE_BIN="$(which cmake 2>&1)";
    if [ $? -eq 0 ]; then
        CMAKE_HOME="$(dirname "$(dirname "$CMAKE_BIN")")" ;
    else
        for TEST_CMAKE_HOME in "C:/Program Files/CMake" "C:/msys64/mingw64" "C:/tools/msys64/mingw64" "C:/Program Files (x86)/CMake" "C:/msys64/mingw32" "C:/tools/msys64/mingw32" ; do
            if [ -e "$TEST_CMAKE_HOME/bin/cmake.exe" ]; then
                CMAKE_HOME="$TEST_CMAKE_HOME";
                break ;
            fi
        done

        if [ -z "$CMAKE_HOME" ]; then
            echo "Executable cmake not found ,please input the CMAKE_HOME(which contains bin/cmake) and then press ENTER.";
            read -r -p "CMAKE_HOME: " CMAKE_HOME;
            CMAKE_HOME="${CMAKE_HOME//\\/\/}";
        fi
        export PATH="$CMAKE_HOME/bin;$PATH";
    fi
fi

if [ ! -e "$CMAKE_HOME/bin/cmake" ]; then
    echo "Can not find $CMAKE_HOME/bin/cmake , try $CMAKE_HOME/bin/cmake.exe.";
    if [ ! -e "$CMAKE_HOME/bin/cmake.exe" ]; then
        echo "Can not find cmake in $CMAKE_HOME, exit now.";
        exit 1;
    elif [ -z "$CMAKE_BIN" ]; then
        CMAKE_BIN="$CMAKE_HOME/bin/cmake.exe";
    fi
elif [ -z "$CMAKE_BIN" ]; then
    CMAKE_BIN="$CMAKE_HOME/bin/cmake";
fi

export CMAKE_HOME ;
echo "$CMAKE_HOME";

if [ -z "SYSTEM_NAME" ]; then
    echo "SYSTEM_NAME not found ,please input the SYSTEM_NAME and then press ENTER.";
    read -r -p "SYSTEM_NAME: " SYSTEM_NAME;
fi

printf "Checking system ...             ";
echo "$SYSTEM_NAME";

if [ -z "$CMAKE_GENERATOR" ]; then
    echo "CMAKE_GENERATOR not found ,please input the CMAKE_GENERATOR(and then press ENTER.";
    read -r -p "CMAKE_GENERATOR: " CMAKE_GENERATOR;
fi

if [ ! -z "$CMAKE_GENERATOR_PLATFORM" ]; then
    CMAKE_GENERATOR_PLATFORM_CMD="-A $CMAKE_GENERATOR_PLATFORM";
fi

echo "====================================================================================";
echo "=== CMAKE_HOME                = $CMAKE_HOME";
echo "=== SYSTEM_NAME               = $SYSTEM_NAME";
echo "=== CMAKE_GENERATOR           = $CMAKE_GENERATOR";
echo "=== CMAKE_GENERATOR_PLATFORM  = $CMAKE_GENERATOR_PLATFORM";
echo "====================================================================================";

WAIT_LEFT_SECONDS=5;
printf "Wait $WAIT_LEFT_SECONDS seconds, and then start to generate project: ";

which sleep > /dev/null 2>&1;
if [ $? -eq 0 ]; then
    function sleep_for_1sec() {
        sleep 1;
    }
else
    function sleep_for_1sec() {
        usleep 1000000;
    }
fi

while [ $WAIT_LEFT_SECONDS -gt 0 ]; do
    printf "$WAIT_LEFT_SECONDS .. ";
    let WAIT_LEFT_SECONDS=$WAIT_LEFT_SECONDS-1;
    sleep_for_1sec ;
done

echo "start project on third party mode at $SCRIPT_DIR/../../";

if [ -z "$BUILD_ROOT_PREFIX" ]; then
    BUILD_ROOT_PREFIX="$SCRIPT_DIR";
fi

if [ -z "$INSTALL_PREFIX" ]; then
    INSTALL_PREFIX="$BUILD_ROOT_PREFIX/$SYSTEM_NAME/Output";
fi

mkdir -p "$BUILD_ROOT_PREFIX/$SYSTEM_NAME";

cd "$BUILD_ROOT_PREFIX/$SYSTEM_NAME";

cmake -G "$CMAKE_GENERATOR" $CMAKE_GENERATOR_PLATFORM_CMD           \
    "$SCRIPT_DIR/../../" -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"   \
    -DPROJECT_ATFRAME_BUILD_THIRD_PARTY_BUSYBOX_MODE=ON             \
    -DPROJECT_ATFRAME_BUILD_THIRD_PARTY=ON                          \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=YES                         \
    "$@";

