#!/bin/bash

# CMAKE_HOME
# cmake
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

if [ -z "$CMAKE_BIN" ]; then
    if [ ! -e "$CMAKE_HOME/bin/cmake" ]; then
        echo "Can not find $CMAKE_HOME/bin/cmake , try $CMAKE_HOME/bin/cmake.exe.";
        if [ ! -e "$CMAKE_HOME/bin/cmake.exe" ]; then
            echo "Can not find cmake in $CMAKE_HOME, exit now.";
            exit 1;
        elif [ -z "$CMAKE_BIN" ]; then
            CMAKE_BIN="$CMAKE_HOME/bin/cmake.exe";
        fi
    else
        CMAKE_BIN="$CMAKE_HOME/bin/cmake";
    fi
fi

export CMAKE_HOME ;
