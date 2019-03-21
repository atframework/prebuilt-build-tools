#!/bin/bash

cd "$(dirname "$0")";

export ARCH="x86_64";

if [ -z "$CFLAGS" ]; then
    export CFLAGS="-m64";
else
    export CFLAGS="$CFLAGS -m64";
fi

if [ -z "$CXXFLAGS" ]; then
    export CXXFLAGS="-m64";
else
    export CXXFLAGS="$CXXFLAGS -m64";
fi

chmod +x ./GenerateUnixGo.sh ;

./GenerateUnixGo.sh -DPROJECT_ATFRAME_TARGET_CPU_ABI=x86_64 "$@" ;
