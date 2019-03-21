#!/bin/bash

cd "$(dirname "$0")";

export ARCH="x86";

if [ -z "$CFLAGS" ]; then
    export CFLAGS="-m32";
else
    export CFLAGS="$CFLAGS -m32";
fi

if [ -z "$CXXFLAGS" ]; then
    export CXXFLAGS="-m32";
else
    export CXXFLAGS="$CXXFLAGS -m32";
fi

chmod +x ./GenerateUnixGo.sh ;

./GenerateUnixGo.sh -DPROJECT_ATFRAME_BUILD_THIRD_PARTY=ON -DCMAKE_SYSTEM_PROCESSOR=x86 "$@" ;
