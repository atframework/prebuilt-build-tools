if (CMAKE_HOST_WIN32)
    set (ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL "\r\n")
elseif (CMAKE_HOST_APPLE)
    set (ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL "\r")
else ()
    set (ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL "\n")
endif ()

if (CMAKE_HOST_WIN32 OR MINGW OR CYGWIN)
    include ("${CMAKE_CURRENT_LIST_DIR}/msys2/Import.cmake")

    if (${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL AMD64 OR ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL x86_64 OR ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL x64)
        set(ATFRAME_THIRD_PARTY_BUILDTOOLS_WINDOWS_BUSYBOX_BIN "${PROJECT_SOURCE_DIR}/BuildTools/BusyBox/busybox64.exe")
    else ()
        set(ATFRAME_THIRD_PARTY_BUILDTOOLS_WINDOWS_BUSYBOX_BIN "${PROJECT_SOURCE_DIR}/BuildTools/BusyBox/busybox.exe")
    endif ()

    string(REPLACE "\\" "/" ATFRAME_THIRD_PARTY_BUILDTOOLS_WINDOWS_BUSYBOX_BIN ${ATFRAME_THIRD_PARTY_BUILDTOOLS_WINDOWS_BUSYBOX_BIN})
endif ()


if (ANDROID)        # Android的额外适配
    message (STATUS "ANDROID_NDK: ${ANDROID_NDK}")
    set(ATFRAME_THIRD_PARTY_BUILDTOOLS_ANDROID_ADDITIONAL_PATH "${ANDROID_HOST_PREBUILTS}/bin" "${ANDROID_TOOLCHAIN_ROOT}/bin" "${ANDROID_TOOLCHAIN_ROOT}/${ANDROID_TOOLCHAIN_NAME}/bin")
    if (CMAKE_HOST_WIN32)
        if (PROJECT_3RD_PARTY_MSYS2_BASH)
            set (ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH ${PROJECT_3RD_PARTY_MSYS2_BASH})
        elseif (EXISTS "/usr/bin/bash")
            set (ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH "/usr/bin/bash")
        elseif (EXISTS "/bin/bash")
            set (ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH "/bin/bash")
        else ()
            set (ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH ${PROJECT_3RD_PARTY_MSYS2_BASH})
        endif ()
    else ()
        if (EXISTS "/usr/bin/bash")
            set (ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH "/usr/bin/bash")
        elseif (EXISTS "/bin/bash")
            set (ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH "/bin/bash")
        else ()
            set (ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH "/sbin/bash")
        endif ()
    endif ()

    set (ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT "${CMAKE_BINARY_DIR}/Build-${CMAKE_SYSTEM_NAME}-${PROJECT_ATFRAME_TARGET_CPU_ABI}/android-ndk-run.sh" CACHE FILEPATH "Android NDK Environment Loader")
    set (ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_RUN_LOG "${CMAKE_BINARY_DIR}/Build-${CMAKE_SYSTEM_NAME}-${PROJECT_ATFRAME_TARGET_CPU_ABI}/android-ndk-run.log")
    file(WRITE ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_RUN_LOG} "Bash: ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH}\n\n") 
    file(WRITE ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT} 
    "#!/bin/bash

BUSYBOX_MODE=0;
if [ \$BUSYBOX_MODE -eq 0 ]; then
    CYGPATH_BIN=$(which cygpath 2>ignore-log.txt);
    PATH_ENV_SEP=\":\";
else
    CYGPATH_BIN=\"\";
    PATH_ENV_SEP=\";\";
fi

if [ ! -z \"\$CYGPATH_BIN\" ]; then
    function convert_path() {
        echo \"\$(cygpath -u \"\$1\")\";
    }
else
    function convert_path() {
        echo \"\$1\";
    }
fi

export ANDROID_NDK=\"\$(convert_path \"$ENV{ANDROID_NDK}\")\";
export ANDROID_NDK_HOME=\"\$(convert_path \"$ENV{ANDROID_NDK}\")\";
export AS=\"\$(convert_path \"${ANDROID_TOOLCHAIN_PREFIX}as${ANDROID_TOOLCHAIN_SUFFIX}\")\";
export LD=\"\$(convert_path \"${ANDROID_TOOLCHAIN_PREFIX}ld${ANDROID_TOOLCHAIN_SUFFIX}\")\";
export CC=\"\$(convert_path \"${CMAKE_C_COMPILER}\")\";
export CXX=\"\$(convert_path \"${CMAKE_CXX_COMPILER}\")\";

if [ ! -z \"\$CYGPATH_BIN\" ]; then
    function convert_ndk_path() {
        RET=\"\$1\";
        echo \"\${RET/\"$ENV{ANDROID_NDK}\"/\"\$ANDROID_NDK\"}\";
    }
else
    function convert_ndk_path() {
        echo \"\$1\";
    }
fi

# patch for android ndk config
CC_DIR_NAME=\"\$(dirname \"\$CC\")\";
export PATH=\"\$CC_DIR_NAME:\$PATH\";
export CC=\$(basename \"\$CC\");
export CXX=\$(basename \"\$CXX\");
# export CC=\${CC%%.exe};
# export CXX=\${CXX%%.exe};

# convert CFLAGS CXXFLAGS ASMFLAGS LDFLAGS
    ")

    foreach (EXT_PATH IN LISTS ATFRAME_THIRD_PARTY_BUILDTOOLS_ANDROID_ADDITIONAL_PATH)
        file(APPEND ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT} "
export PATH=\"\$(convert_path \"${EXT_PATH}\")\$PATH_ENV_SEP\$PATH\";
")
    endforeach ()

    if (CMAKE_AR)
        file(APPEND ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT} "
export AR=\"\$(basename \"${CMAKE_AR}\")\"")
    endif ()

    if (CMAKE_C_FLAGS OR CMAKE_C_FLAGS_RELEASE)
        file(APPEND ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT} "
export CFLAGS=\"\$(convert_ndk_path \"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}\")\"")
    endif ()

    if (CMAKE_CXX_FLAGS OR CMAKE_CXX_FLAGS_RELEASE)
        file(APPEND ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT} "
export CXXFLAGS=\"\$(convert_ndk_path \"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}\")\"")
    endif ()

    if (CMAKE_ASM_FLAGS OR CMAKE_ASM_FLAGS_RELEASE)
        file(APPEND ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT} "
export ASFLAGS=\"\$(convert_ndk_path \"${CMAKE_ASM_FLAGS} ${CMAKE_ASM_FLAGS_RELEASE}\")\"")
    endif ()

    if (CMAKE_STATIC_LINKER_FLAGS OR CMAKE_EXE_LINKER_FLAGS)
        file(APPEND ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT} "
export LDFLAGS=\"\$(convert_ndk_path \"${CMAKE_STATIC_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS}\")\"")
    endif ()

    if (CMAKE_RANLIB)
        file(APPEND ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT} "
export RANLIB=\"\$(basename \"${CMAKE_RANLIB}\")\"")
    endif ()

    file(APPEND ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT} "

echo \"\";
echo \"================================================================================================\";
echo \"PATH=\$PATH\";
echo \"ANDROID_NDK=\$ANDROID_NDK\";
echo \"CC=\$CC (in \$CC_DIR_NAME)\";
echo \"CXX=\$CC (in \$CC_DIR_NAME)\";
echo \"LD=\$LD\";
echo \"AS=\$AS\";
echo \"AR=\$AR\";
echo \"CFLAGS=\$CFLAGS\";
echo \"CXXFLAGS=\$CXXFLAGS\";
echo \"ASFLAGS=\$ASFLAGS\";
echo \"LDFLAGS=\$LDFLAGS\";
echo \"RANLIB=\$RANLIB\";

echo \"================================================================================================\";
echo \"CmdLog: \$(convert_path \"${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_RUN_LOG}\")\";
echo \"Run: $@\";
echo \"\$PWD:\n\t$@\" >> \"\$(convert_path \"${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_RUN_LOG}\")\";

\"\$@\"
    ")
    ATPBMakeExecutable(${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT})
elseif (MSVC)       # Visual Studio的额外适配
    get_filename_component(ATFRAME_THIRD_PARTY_CL_COMPILER_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)
    set(ENV{PATH} "${ATFRAME_THIRD_PARTY_CL_COMPILER_DIR};$ENV{PATH}")
elseif (UNIX OR MINGW OR CYGWIN)
    set (ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT "${CMAKE_BINARY_DIR}/Build-${CMAKE_SYSTEM_NAME}-${PROJECT_ATFRAME_TARGET_CPU_ABI}/unix-config-run.sh" CACHE FILEPATH "Unix Environment Loader")
    set (ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_RUN_LOG "${CMAKE_BINARY_DIR}/Build-${CMAKE_SYSTEM_NAME}-${PROJECT_ATFRAME_TARGET_CPU_ABI}/unix-config-run.log")
    file(WRITE ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_RUN_LOG} "") 
    file(WRITE ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} 
    "#!/bin/bash

CYGPATH_BIN=$(which cygpath 2>ignore-log.txt);

if [ ! -z \"\$CYGPATH_BIN\" ]; then
    function convert_path() {
        echo \"\$(cygpath -u \"\$1\")\";
    }
else
    function convert_path() {
        echo \"\$1\";
    }
fi
export CC=\"${CMAKE_C_COMPILER}\";
export CXX=\"${CMAKE_CXX_COMPILER}\";

# convert CFLAGS CXXFLAGS ASMFLAGS LDFLAGS
    ")

    foreach (EXT_PATH IN LISTS ATFRAME_THIRD_PARTY_BUILDTOOLS_UNIX_ADDITIONAL_PATH)
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export PATH=\"${EXT_PATH}:\$PATH\";")
    endforeach ()

    if (ENV{LD})
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export LD=\"$ENV{LD}\" ;")
    endif ()

    if (ENV{AS})
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export AS=\"$ENV{LD}\" ;")
    endif ()

    if (ENV{STRIP})
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export STRIP=\"$ENV{STRIP}\" ;")
    endif ()

    if (ENV{NM})
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export NM=\"$ENV{STRIP}\" ;")
    endif ()

    if (CMAKE_AR)
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export AR=\"${CMAKE_AR}\" ;")
    endif ()

    if (CMAKE_C_FLAGS OR CMAKE_C_FLAGS_RELEASE)
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export CFLAGS=\"${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}\"")
    endif ()

    if (CMAKE_CXX_FLAGS OR CMAKE_CXX_FLAGS_RELEASE)
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export CXXFLAGS=\"${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}\"")
    endif ()

    if (CMAKE_ASM_FLAGS OR CMAKE_ASM_FLAGS_RELEASE)
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export ASFLAGS=\"${CMAKE_ASM_FLAGS} ${CMAKE_ASM_FLAGS_RELEASE}\"")
    endif ()

    if (CMAKE_STATIC_LINKER_FLAGS OR CMAKE_EXE_LINKER_FLAGS)
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export LDFLAGS=\"${CMAKE_STATIC_LINKER_FLAGS} ${CMAKE_EXE_LINKER_FLAGS}\"")
    endif ()

    if (CMAKE_RANLIB)
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export RANLIB=\"${CMAKE_RANLIB}\"")
    endif ()

    if (OSX_SYSROOT)
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export OSX_SYSROOT=\"${OSX_SYSROOT}\"")
    endif ()

    if (OSX_ARCHITECTURES)
        file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_BUILDTOOLS_EOL}export OSX_ARCHITECTURES=\"${OSX_ARCHITECTURES}\"")
    endif ()

    file(APPEND ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "
echo \"\";
echo \"================================================================================================\";
echo \"PATH=\$PATH\";
echo \"CC=\$CC\";
echo \"CXX=\$CXX\";
echo \"LD=\$LD\";
echo \"AS=\$AS\";
echo \"AR=\$AR\";
echo \"LD=\$LD\";
echo \"STRIP=\$STRIP\";
echo \"NM=\$NM\";
echo \"CFLAGS=\$CFLAGS\";
echo \"CXXFLAGS=\$CXXFLAGS\";
echo \"ASFLAGS=\$ASFLAGS\";
echo \"LDFLAGS=\$LDFLAGS\";
echo \"RANLIB=\$RANLIB\";
echo \"OSX_SYSROOT=\$OSX_SYSROOT\";
echo \"OSX_ARCHITECTURES=\$OSX_ARCHITECTURES\";

echo \"================================================================================================\";
echo \"CmdLog: \$(convert_path \"${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_RUN_LOG}\")\";

OUTPUT_COMMAND_LINE=\"\";
for line in \"\$\@\"; do OUTPUT_COMMAND_LINE=\"\$OUTPUT_COMMAND_LINE \\\"\$line\\\"\"; done ;
echo \"Run: \$OUTPUT_COMMAND_LINE\";
echo \"\$PWD:\\n\\t\$OUTPUT_COMMAND_LINE\" >> \"\$(convert_path \"${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_RUN_LOG}\")\";

\"\$@\"
    ")
endif ()
