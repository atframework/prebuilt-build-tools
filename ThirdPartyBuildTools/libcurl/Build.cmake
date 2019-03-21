############################################################
#        Source: https://curl.haxx.se/download.html        #
############################################################


set (ATFRAME_THIRD_PARTY_LIBCURL_VERSION "7.64.0")
set (ATFRAME_THIRD_PARTY_LIBCURL_SRC_DIR "${ATFRAME_THIRD_PARTY_TARGET_LIBCURL_BUILD_DIR}/source/curl-${ATFRAME_THIRD_PARTY_LIBCURL_VERSION}")

unset (ATFRAME_THIRD_PARTY_LIBCURL_BUILD_OPTIONS)

if (NOT PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL x86 AND NOT PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL x86_64)
    list (APPEND ATFRAME_THIRD_PARTY_LIBCURL_BUILD_OPTIONS "-DBUILD_CURL_EXE=NO")
endif ()

# standard cmake project
if (CMAKE_HOST_WIN32 OR CYGWIN OR MINGW OR NOT ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT)
    ATPBTargetBuildThirdPartyByCMake(${ATFRAME_THIRD_PARTY_LIBCURL_SRC_DIR} 
        "-DBUILD_SHARED_LIBS=NO" ${ATFRAME_THIRD_PARTY_LIBCURL_BUILD_OPTIONS} "-DCURL_STATIC_CRT=NO"
        "-DUSE_MANUAL=NO" "-DBUILD_TESTING=NO"
        "-DCMAKE_USE_OPENSSL=YES" "-DCMAKE_USE_MBEDTLS=NO" "-DCURL_CA_PATH=auto"
        "-DOPENSSL_USE_STATIC_LIBS=YES" 
        "-DOPENSSL_ROOT_DIR=${ATFRAME_THIRD_PARTY_TARGET_OPENSSL_INSTALL_PREFIX}"
        "-DCMAKE_FIND_ROOT_PATH=${ATFRAME_THIRD_PARTY_TARGET_OPENSSL_INSTALL_PREFIX}"
    )
else ()
    ATPBTargetBuildThirdPartyByConfigure(
        "${ATFRAME_THIRD_PARTY_LIBCURL_SRC_DIR}/configure"
        BASH ${ATFRAME_THIRD_PARTY_UNIX_BUILD_CONFIG_SCRIPT}
        ARGS "--with-pic=yes" "--enable-shared=no" "--enable-static=yes" "--disable-manual"
             "--with-ssl=${ATFRAME_THIRD_PARTY_TARGET_OPENSSL_INSTALL_PREFIX}"
    )
endif ()

add_dependencies(libcurl install-openssl)
