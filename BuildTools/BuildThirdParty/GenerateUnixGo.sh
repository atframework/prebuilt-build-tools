#!/bin/bash

# CMAKE_HOME
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)";
SCRIPT_DIR="${SCRIPT_DIR//\\//}";

source "$SCRIPT_DIR/LoadCMakeEnvs.sh" ;

if [ "x$SYSTEM_NAME" == "x" ]; then
    SYSTEM_NAME="$(uname -s)-$ARCH";
    printf "Checking system ...             ";
fi
echo "$SYSTEM_NAME";

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

if [ $USE_NINJA -ne 0 ]; then
    echo "$NINJA_BIN";
else
    echo "not found";
fi

# prefer to use clang
printf "Checking compiler ...           ";
if [ -z "$CC" ]; then
    CC="$(which clang 2>/dev/null)";
    if [ $? -ne 0 ]; then
        CC="";
    fi
fi

if [ -z "$CXX" ]; then
    CXX="$(which clang++ 2>/dev/null)";
    if [ $? -ne 0 ]; then
        CXX="";
    fi
fi

if [ -z "$CC" ] || [ -z "$CXX" ]; then
    CC="$(which gcc 2>/dev/null)";
    CXX="$(which g++ 2>/dev/null)";
fi

if [ -z "$CC" ] || [ -z "$CXX" ]; then
    echo "Can not find clang/clang++ or gcc/g++.";
    exit 3;
fi

echo "$CC / $CXX";

printf "Checking ar ...                 ";

if [ -z "$AR" ]; then
    AR="$(which llvm-ar 2>/dev/null)";
    if [ $? -ne 0 ]; then
        AR="";
    fi

    if [ -z "$AR" ]; then
        AR="$(which ar 2>/dev/null)";
    fi
    if [ $? -ne 0 ]; then
        AR="";
    fi
fi

if [ -z "$AR" ]; then
    echo "Can not find llvm-ar/ar.";
    exit 4;
fi

echo "$AR";

printf "Checking ld ...                 ";
if [ -z "$LD" ]; then
    LD="$(which ld.lld 2>/dev/null)";
    if [ $? -ne 0 ]; then
        LD="";
    fi

    if [ -z "$LD" ]; then
        LD="$(which lld 2>/dev/null)";
    fi
    if [ $? -ne 0 ]; then
        LD="";
    fi

    if [ -z "$LD" ]; then
        LD="$(which ld 2>/dev/null)";
    fi
    if [ $? -ne 0 ]; then
        LD="";
    fi
fi

if [ -z "$LD" ]; then
    echo "Can not find ld.lld/lld/ld.";
    exit 5;
fi

echo "$LD";

which cygpath > /dev/null 2>&1;
if [ $? -eq 0 ]; then
    if [ ! -z "$CMAKE_HOME" ]; then
        CMAKE_HOME="$(cygpath -m -a "$CMAKE_HOME")";
    fi
    if [ ! -z "$NINJA_BIN" ]; then
        NINJA_BIN="$(cygpath -m -a "$NINJA_BIN")";
    fi
    if [ ! -z "$CC" ]; then
        CC="$(cygpath -m -a "$CC")";
    fi
    if [ ! -z "$CXX" ]; then
        CXX="$(cygpath -m -a "$CXX")";
    fi
    if [ ! -z "$AR" ]; then
        AR="$(cygpath -m -a "$AR")";
    fi
    if [ ! -z "$LD" ]; then
        LD="$(cygpath -m -a "$LD")";
    fi
fi

echo "====================================================================================";
echo "=== CMAKE_HOME    = $CMAKE_HOME";
echo "=== SYSTEM_NAME   = $SYSTEM_NAME";
echo "=== USE_NINJA     = $USE_NINJA";
echo "=== NINJA_BIN     = $NINJA_BIN";
echo "=== CC            = $CC";
echo "=== CXX           = $CXX";
echo "=== AR            = $AR";
echo "=== LD            = $LD";
echo "====================================================================================";

WAIT_LEFT_SECONDS=5;
printf "Wait $WAIT_LEFT_SECONDS seconds, and then start to generate project: ";

which usleep > /dev/null 2>&1;
if [ $? -eq 0 ]; then
    function sleep_for_1sec() {
        usleep 1000000;
    }
else
    function sleep_for_1sec() {
        sleep 1;
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

if [ -e "/bin/bash" ] || [ -e "/usr/bin/bash" ]; then
    PROJECT_ATFRAME_BUILD_THIRD_PARTY_BUSYBOX_MODE="OFF";
else
    PROJECT_ATFRAME_BUILD_THIRD_PARTY_BUSYBOX_MODE="ON";
fi

"$CMAKE_BIN" -G "$CMAKE_GENERATOR" "$SCRIPT_DIR/../../" -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX"               \
    -DPROJECT_ATFRAME_BUILD_THIRD_PARTY=ON                                                              \
    -DPROJECT_ATFRAME_BUILD_THIRD_PARTY_BUSYBOX_MODE=$PROJECT_ATFRAME_BUILD_THIRD_PARTY_BUSYBOX_MODE    \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=YES                                                             \
    "-DCMAKE_C_COMPILER=$CC" "-DCMAKE_CXX_COMPILER=$CXX" "-DCMAKE_AR=$AR"                               \
    "$@";

if [ $? -eq 0 ]; then
    "$CMAKE_BIN" --build . ;
fi
