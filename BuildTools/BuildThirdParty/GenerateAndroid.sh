#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)";
SCRIPT_DIR="${SCRIPT_DIR//\\//}";

source "$SCRIPT_DIR/LoadAndroidEnvs.sh";

for ARCH in $ANDROID_ARCHS; do
    export SYSTEM_NAME="Android-$ARCH" ;
    export ARCH=$ARCH ;
    chmod +x "$SCRIPT_DIR/GenerateAndroidGo.sh" ;
    "$SCRIPT_DIR/GenerateAndroidGo.sh" ;

    LAST_EXIT_CODE=$?;
    if [ $LAST_EXIT_CODE -ne 0 ]; then
        exit $LAST_EXIT_CODE;
    fi
done
