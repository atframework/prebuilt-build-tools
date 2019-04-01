############################################################
#   Source: https://github.com/protocolbuffers/protobuf    #
############################################################

find_package(Git)
if(NOT GIT_FOUND)
    message(FATAL_ERROR "git not found")
endif()

set (ATFRAME_THIRD_PARTY_MSGPACK_VERSION  "3.1.1")
set (ATFRAME_THIRD_PARTY_MSGPACK_PKG_DIR  "${ATFRAME_THIRD_PARTY_TARGET_MSGPACK_BUILD_DIR}/source")
set (ATFRAME_THIRD_PARTY_MSGPACK_PKG_PATH "${ATFRAME_THIRD_PARTY_MSGPACK_PKG_DIR}/msgpack-${ATFRAME_THIRD_PARTY_MSGPACK_VERSION}.tar.gz")
set (ATFRAME_THIRD_PARTY_MSGPACK_SRC_DIR  "${ATFRAME_THIRD_PARTY_MSGPACK_PKG_DIR}/msgpack-${ATFRAME_THIRD_PARTY_MSGPACK_VERSION}")

if (NOT EXISTS ${ATFRAME_THIRD_PARTY_MSGPACK_PKG_DIR})
    file (MAKE_DIRECTORY ${ATFRAME_THIRD_PARTY_MSGPACK_PKG_DIR})
endif ()

if (NOT EXISTS ${ATFRAME_THIRD_PARTY_MSGPACK_SRC_DIR})
    if (NOT EXISTS ${ATFRAME_THIRD_PARTY_MSGPACK_PKG_PATH})
        file(DOWNLOAD "https://github.com/msgpack/msgpack-c/releases/download/cpp-${ATFRAME_THIRD_PARTY_MSGPACK_VERSION}/msgpack-${ATFRAME_THIRD_PARTY_MSGPACK_VERSION}.tar.gz" ${ATFRAME_THIRD_PARTY_MSGPACK_PKG_PATH} SHOW_PROGRESS)
    endif ()

    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar xvf ${ATFRAME_THIRD_PARTY_MSGPACK_PKG_PATH}
        WORKING_DIRECTORY ${ATFRAME_THIRD_PARTY_MSGPACK_PKG_DIR}
    )
endif ()

if (NOT EXISTS ${ATFRAME_THIRD_PARTY_MSGPACK_SRC_DIR})
    message(FATAL_ERROR "${ATFRAME_THIRD_PARTY_MSGPACK_SRC_DIR} not found.")
endif ()


add_custom_target(install-msgpack ALL 
    ${CMAKE_COMMAND} -E copy_directory "${ATFRAME_THIRD_PARTY_MSGPACK_SRC_DIR}/include" "${ATFRAME_THIRD_PARTY_TARGET_MSGPACK_INSTALL_PREFIX}/include"
)

set_property(TARGET install-msgpack PROPERTY FOLDER "install/${ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE}")
