﻿############################################################
#     Source: https://github.com/atframework/libatapp/     #
############################################################

find_package(Git)
if(NOT GIT_FOUND)
    message(FATAL_ERROR "git not found")
endif()

set (ATFRAME_THIRD_PARTY_LIBATAPP_PKG_DIR   "${ATFRAME_THIRD_PARTY_TARGET_LIBATAPP_BUILD_DIR}/source")
set (ATFRAME_THIRD_PARTY_LIBATAPP_REPO_DIR  "${ATFRAME_THIRD_PARTY_LIBATAPP_PKG_DIR}/libatapp")
set (ATFRAME_THIRD_PARTY_LIBATBUS_REPO_DIR  "${ATFRAME_THIRD_PARTY_LIBATAPP_PKG_DIR}/libatbus")

if (NOT EXISTS ${ATFRAME_THIRD_PARTY_LIBATAPP_PKG_DIR})
    file (MAKE_DIRECTORY ${ATFRAME_THIRD_PARTY_LIBATAPP_PKG_DIR})
endif ()

if (NOT EXISTS "${ATFRAME_THIRD_PARTY_LIBATAPP_REPO_DIR}/.git")
    if (EXISTS ${ATFRAME_THIRD_PARTY_LIBATAPP_REPO_DIR})
        file (REMOVE_RECURSE ${ATFRAME_THIRD_PARTY_LIBATAPP_REPO_DIR})
    endif ()

    execute_process(
        COMMAND ${GIT_EXECUTABLE} clone -b master "https://github.com/atframework/libatapp.git" ${ATFRAME_THIRD_PARTY_LIBATAPP_REPO_DIR}
        WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_LIBATAPP_PKG_DIR}
    )
else ()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} reset --hard
        COMMAND ${GIT_EXECUTABLE} pull
        WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_LIBATAPP_REPO_DIR}
    )
endif ()

if (NOT EXISTS "${ATFRAME_THIRD_PARTY_LIBATBUS_REPO_DIR}/.git")
    if (EXISTS ${ATFRAME_THIRD_PARTY_LIBATBUS_REPO_DIR})
        file (REMOVE_RECURSE ${ATFRAME_THIRD_PARTY_LIBATBUS_REPO_DIR})
    endif ()

    execute_process(
        COMMAND ${GIT_EXECUTABLE} clone -b master "https://github.com/atframework/libatbus.git" ${ATFRAME_THIRD_PARTY_LIBATBUS_REPO_DIR}
        WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_LIBATAPP_PKG_DIR}
    )
else ()
    execute_process(
        COMMAND ${GIT_EXECUTABLE} reset --hard
        COMMAND ${GIT_EXECUTABLE} pull
        WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_LIBATBUS_REPO_DIR}
    )
endif ()

# standard cmake project
ATPBTargetBuildThirdPartyByCMake(${ATFRAME_THIRD_PARTY_LIBATAPP_REPO_DIR}
    "-DATFRAME_UTILS_ROOT=${ATFRAME_UTILS_ROOT}" "-DLIBATBUS_ROOT=${ATFRAME_THIRD_PARTY_LIBATBUS_REPO_DIR}"
    "-DMSGPACK_ROOT=${ATFRAME_THIRD_PARTY_TARGET_MSGPACK_INSTALL_PREFIX}"
    "-DLibuv_ROOT=${ATFRAME_THIRD_PARTY_TARGET_LIBUV_INSTALL_PREFIX}" "-DENABLE_NETWORK=ON" "-DCURL_ROOT=${ATFRAME_THIRD_PARTY_TARGET_LIBCURL_INSTALL_PREFIX}"
    "-DCRYPTO_USE_OPENSSL=ON" "-DOPENSSL_ROOT_DIR=${ATFRAME_THIRD_PARTY_LIBCURL_SSL}" "-DCMAKE_FIND_ROOT_PATH=${ATFRAME_THIRD_PARTY_LIBCURL_SSL}"
    "-DPROJECT_ENABLE_SAMPLE=OFF" "-DPROJECT_ENABLE_UNITTEST=OFF" "-DPROJECT_ENABLE_TOOLS=ON" "-DLOG_WRAPPER_ENABLE_LUA_SUPPORT=OFF"
)

add_custom_target(install-libiniloader 
    ${CMAKE_COMMAND} -E copy "${ATFRAME_THIRD_PARTY_LIBATAPP_REPO_DIR}/3rd_party/libiniloader/repo/ini_loader.h" "${ATFRAME_THIRD_PARTY_TARGET_LIBATAPP_INSTALL_PREFIX}/include/ini_loader.h"
    DEPENDS libatapp
)
set_property(TARGET install-libiniloader PROPERTY FOLDER "install/${ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE}")

add_dependencies(libatapp install-libuv install-libcurl install-msgpack)
add_dependencies(install-libatapp install-libiniloader)
