#!/bin/bash

# CMAKE_HOME

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)";
SCRIPT_DIR="${SCRIPT_DIR//\\//}";

source "$SCRIPT_DIR/LoadCMakeEnvs.sh" ;
source "$SCRIPT_DIR/../MacSetting.sh";


if [ -z "$BUILD_ROOT_PREFIX" ]; then
    BUILD_ROOT_PREFIX="$SCRIPT_DIR";
fi

