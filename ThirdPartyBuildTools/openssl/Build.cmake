############################################################
#         Source: https://www.openssl.org/source/          #
############################################################


# openssl 源码中要加一个patch， Configurations/15-android.conf 中需要修改一下用以适配Windows环境编译
# 1. $ndk = canonpath($ndk); 后面加一行 $ndk =~ s/\\/\//g; 
# 2. 把 if (which("clang") =~ m|^$ndk/.*/prebuilt/([^/]+)/|) 换成
#   my $clang_bin = which("clang");
#   $clang_bin =~ s/\\/\//g;
#   if ($clang_bin =~ m|^$ndk/.*/prebuilt/([^/]+)/|) {
# 3. 把 if (which("llvm-ar") =~ m|^$ndk/.*/prebuilt/([^/]+)/|) 换成
#   my $llvm_ar_bin = which("llvm-ar");
#   $llvm_ar_bin =~ s/\\/\//g;
#   if ($llvm_ar_bin =~ m|^$ndk/.*/prebuilt/([^/]+)/|)
# 4. 把文件 Configurations/unix-checker.pm 里的反斜杠检查（if语句）注释掉

if (OPENSSL_ROOT_DIR)
    add_custom_target(openssl ALL 
        ${CMAKE_COMMAND} -E echo "Using prebuilt openssl at ${OPENSSL_ROOT_DIR}"
    )

    add_custom_target(install-openssl ALL 
        ${CMAKE_COMMAND} -E echo "Using prebuilt openssl at ${OPENSSL_ROOT_DIR} install-openssl"
        DEPENDS openssl
    )

    set_property(TARGET install-openssl PROPERTY FOLDER "install/${ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE}")

    set (ATFRAME_THIRD_PARTY_TARGET_OPENSSL_INSTALL_PREFIX ${OPENSSL_ROOT_DIR} CACHE PATH "Prebuilt openssl" FORCE)
else ()

    set (ATFRAME_THIRD_PARTY_OPENSSL_VERSION  "1.1.1b")
    set (ATFRAME_THIRD_PARTY_OPENSSL_PKG_DIR  "${ATFRAME_THIRD_PARTY_TARGET_OPENSSL_BUILD_DIR}/source")
    set (ATFRAME_THIRD_PARTY_OPENSSL_PKG_PATH "${ATFRAME_THIRD_PARTY_OPENSSL_PKG_DIR}/openssl-${ATFRAME_THIRD_PARTY_OPENSSL_VERSION}.tar.gz")
    set (ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR  "${ATFRAME_THIRD_PARTY_OPENSSL_PKG_DIR}/openssl-${ATFRAME_THIRD_PARTY_OPENSSL_VERSION}")

    if (NOT EXISTS ${ATFRAME_THIRD_PARTY_OPENSSL_PKG_DIR})
        file (MAKE_DIRECTORY ${ATFRAME_THIRD_PARTY_OPENSSL_PKG_DIR})
    endif ()

    if (NOT EXISTS ${ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR})
        if (NOT EXISTS ${ATFRAME_THIRD_PARTY_OPENSSL_PKG_PATH})
            file(DOWNLOAD "https://www.openssl.org/source/openssl-${ATFRAME_THIRD_PARTY_OPENSSL_VERSION}.tar.gz" ${ATFRAME_THIRD_PARTY_OPENSSL_PKG_PATH} SHOW_PROGRESS)
        endif ()

        execute_process(
            COMMAND ${CMAKE_COMMAND} -E tar xvf ${ATFRAME_THIRD_PARTY_OPENSSL_PKG_PATH}
            WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_OPENSSL_PKG_DIR}
        )
    endif ()

    if (NOT EXISTS ${ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR})
        message(FATAL_ERROR "${ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR} not found.")
    endif ()

    unset (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OPTIONS)
    list (APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OPTIONS 
        "--prefix\=${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}"
        "--openssldir\=${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}/lib"
        "--release" "no-deprecated" "no-dso" "no-shared"
        "no-tests" "no-external-tests" "no-external-tests" 
        "no-aria" "no-bf" "no-blake2" "no-camellia" "no-cast" "no-idea" 
        "no-md2" "no-md4" "no-mdc2" "no-rc2" "no-rc4" "no-rc5" "no-hw" "no-ssl3"
    )

    # if(NOT ${PROJECT_ATFRAME_TARGET_CPU_ABI} STREQUAL x86_64)
    #     list (APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OPTIONS "no-apps")
    # endif()

    unset (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_ENVS)

    if (NOT MSVC)
        list(APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_ENVS
            "CC=${CMAKE_C_COMPILER}"
            "CXX=${CMAKE_CXX_COMPILER}"
        )
    endif ()

    if (CMAKE_AR)
        list(APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_ENVS "AR=${CMAKE_AR}")
    endif ()

    if (CMAKE_C_FLAGS OR CMAKE_C_FLAGS_RELEASE)
        list(APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_ENVS "CFLAGS=${CMAKE_C_FLAGS} ${CMAKE_C_FLAGS_RELEASE}")
    endif ()

    if (CMAKE_CXX_FLAGS OR CMAKE_CXX_FLAGS_RELEASE)
        list(APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_ENVS "CXXFLAGS=${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE}")
    endif ()

    if (CMAKE_ASM_FLAGS OR CMAKE_ASM_FLAGS_RELEASE)
        list(APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_ENVS "ASFLAGS=${CMAKE_ASM_FLAGS} ${CMAKE_ASM_FLAGS_RELEASE}")
    endif ()

    if (CMAKE_EXE_LINKER_FLAGS)
        list(APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_ENVS "LDFLAGS=${CMAKE_EXE_LINKER_FLAGS}")
    endif ()

    if (CMAKE_RANLIB)
        list(APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_ENVS "RANLIB=${CMAKE_RANLIB}")
    endif ()

    if (CMAKE_STATIC_LINKER_FLAGS)
        list(APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_ENVS "LDFLAGS=${CMAKE_STATIC_LINKER_FLAGS}")
    endif ()

    file(MAKE_DIRECTORY ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX})
    file(MAKE_DIRECTORY ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR})

    if (ANDROID)
        unset(ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CONFIG)
        if (CMAKE_HOST_WIN32)
            if (PROJECT_3RD_PARTY_MSYS2_BASH)
                list (APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CONFIG "env" "PERL=perl" "perl" "${ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR}/Configure")
            else ()
                list (APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CONFIG "env" "PERL=perl" "perl" "${ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR}/Configure")
            endif ()
        else ()
            list (APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CONFIG "${ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR}/config")
        endif ()

        # 这个名字openssl按 ${ANDROID_NDK}/platforms/android-*/ 里的目录名来的
        if(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL armv7)
            set (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OS_COMPILER android-arm)
        elseif(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL aarch64)
            set (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OS_COMPILER android-arm64)
        elseif(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL x86)
            set (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OS_COMPILER android-x86)
        elseif(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL x86_64)
            set (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OS_COMPILER android-x86_64)  
        elseif(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL mips)
            set (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OS_COMPILER android-mips)
        elseif(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL mips64)
            set (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OS_COMPILER android-mips64)
        else()
            message(FATAL_ERROR "Invalid Project CPU ABI: ${PROJECT_ATFRAME_TARGET_CPU_ABI}.")
        endif()

        find_program(ATFRAME_THIRD_PARTY_OPENSSL_BUILD_MAKE NAMES make.exe make PATHS "${ANDROID_HOST_PREBUILTS}/bin" ${ANDROID_HOST_PREBUILTS} NO_DEFAULT_PATH)
        if (NOT ATFRAME_THIRD_PARTY_OPENSSL_BUILD_MAKE)
            message (FATAL_ERROR "Can not find make in ${ANDROID_HOST_PREBUILTS}")
        endif ()

        list (APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OPTIONS "no-stdio" "-D__ANDROID_API__=${ANDROID_PLATFORM_LEVEL}")

        #string(REPLACE "\\" "/" ATFRAME_THIRD_PARTY_OPENSSL_BUILD_PATH_CMD "$ENV{PATH}")
        ATPBExpandListForCommandLine(ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CONFIG_CMD ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CONFIG)
        ATPBExpandListForCommandLine(ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OPTIONS_CMD ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OPTIONS)
        ATPBExpandListForCommandLine(ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OS_COMPILER_CMD ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OS_COMPILER)

        include(ProcessorCount)
        ProcessorCount(CPU_CORE_NUM)

        # cmake的BUG，不支持参数内加等号
        # https://cmake.org/Bug/print_bug_page.php?bug_id=5145
        set (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_PATCH_CONFIG "${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/patch-config.sh")
        file(WRITE ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_PATCH_CONFIG}
        "#!/bin/bash
    cd \"\$(dirname \"\$0\")\";

    ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CONFIG_CMD} ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OPTIONS_CMD} ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OS_COMPILER_CMD} ;
        ")

        # Windows 下的make不支持环境变量语法，这里在loader里已经设置过了，所以直接移除Makefile里的设置即可
        set (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_PATCH_MAKE "${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}/patch-make.sh")
        file(WRITE ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_PATCH_MAKE}
        "#!/bin/bash
    cd \"\$(dirname \"\$0\")\";

    sed -i -e \"s;CC\\\\=\\\"\\\\\\$.CC.\\\"\\\\s*\\\\\\$;\\$;g\" Makefile;

    make -j${CPU_CORE_NUM} ;
        ")
        ATPBMakeExecutable (${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_PATCH_MAKE})

        
        add_custom_target (${ATFRAME_THIRD_PARTY_TARGET_NAME}
            ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH} ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT}
            ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_PATCH_CONFIG}
            COMMAND ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH} ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT} 
                ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_PATCH_MAKE}
            WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}
            COMMENT "Building ${ATFRAME_THIRD_PARTY_TARGET_NAME} at ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}"
            VERBATIM
            SOURCES "${ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR}/Configure"
        )

        set (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_MAKE ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH} ${ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT} make)
    elseif (MSVC)
        if (CMAKE_SIZEOF_VOID_P MATCHES 8)
            if (PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL aarch64)
                set (ATFRAME_THIRD_PARTY_OPENSSL_MSVC_CFG VC-WIN64-ARM)
            else ()
                set (ATFRAME_THIRD_PARTY_OPENSSL_MSVC_CFG VC-WIN64A-masm)
            endif ()
        else ()
            if (PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL armv7)
                set (ATFRAME_THIRD_PARTY_OPENSSL_MSVC_CFG VC-WIN32-ARM)
            else ()
                set (ATFRAME_THIRD_PARTY_OPENSSL_MSVC_CFG VC-WIN32)
                list (APPEND ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OPTIONS "no-asm")
            endif ()
        endif ()
        get_filename_component(ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CL_DIR ${CMAKE_CXX_COMPILER} DIRECTORY)
        get_filename_component(ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CL_NOARCH_DIR ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CL_DIR} DIRECTORY)
        find_program(ATFRAME_THIRD_PARTY_OPENSSL_BUILD_MAKE NAMES nmake.exe nmake 
            PATHS ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CL_NOARCH_DIR} 
            PATH_SUFFIXES x64 x86 arm NO_DEFAULT_PATH)
        if (NOT ATFRAME_THIRD_PARTY_OPENSSL_BUILD_MAKE)
            message (FATAL_ERROR "Can not find nmake.exe in ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_CL_NOARCH_DIR}")
        endif ()
        set (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_MAKE_SUFFIX /I)

        add_custom_target (${ATFRAME_THIRD_PARTY_TARGET_NAME}
            ${PROJECT_3RD_PARTY_PERL_EXEC} "${ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR}/Configure" ${ATFRAME_THIRD_PARTY_OPENSSL_MSVC_CFG}
                ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OPTIONS} ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_ENVS}
            COMMAND ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_MAKE}
            WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}
            COMMENT "Building ${ATFRAME_THIRD_PARTY_TARGET_NAME} at ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}"
            SOURCES "${ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR}/Configure"
        )
    elseif (UNIX OR MINGW)
        include(ProcessorCount)
        ProcessorCount(CPU_CORE_NUM)

        set (ATFRAME_THIRD_PARTY_OPENSSL_BUILD_MAKE make)
        add_custom_target (${ATFRAME_THIRD_PARTY_TARGET_NAME}
                ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT} "${ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR}/config" 
                ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_OPTIONS} ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_ENVS}
            COMMAND ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_MAKE} "-j${CPU_CORE_NUM}"
            WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}
            COMMENT "Building ${ATFRAME_THIRD_PARTY_TARGET_NAME} at ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}"
            SOURCES "${ATFRAME_THIRD_PARTY_OPENSSL_SRC_DIR}/Configure"
        )
    endif()


    add_custom_target ("install-${ATFRAME_THIRD_PARTY_TARGET_NAME}" ALL
        # make writable first
        ${ATFRAME_MAKE_WRITABLE_COMMAND_PREFIX} ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}
        COMMAND ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_MAKE} install ${ATFRAME_THIRD_PARTY_OPENSSL_BUILD_MAKE_SUFFIX}
        WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_BUILD_WORK_DIR}
        COMMENT "Install ${ATFRAME_THIRD_PARTY_TARGET_NAME} into ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}"
        DEPENDS ${ATFRAME_THIRD_PARTY_TARGET_NAME}
    )

    # 通过自定义命令驱动安装
    set_property(TARGET ${ATFRAME_THIRD_PARTY_TARGET_NAME} PROPERTY FOLDER ${ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE})
    set_property(TARGET "install-${ATFRAME_THIRD_PARTY_TARGET_NAME}" PROPERTY FOLDER "install/${ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE}")

endif()