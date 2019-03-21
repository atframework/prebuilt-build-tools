set (PROJECT_CONFIGURE_CMAKE_EXT_DIR ${CMAKE_CURRENT_LIST_DIR})
set (PROJECT_CONFIGURE_CMAKE_TARGET_DIR "${PROJECT_CONFIGURE_CMAKE_EXT_DIR}/Target")

include ("${PROJECT_CONFIGURE_CMAKE_EXT_DIR}/ProjectInstallTarget.cmake")
include ("${PROJECT_CONFIGURE_CMAKE_EXT_DIR}/ProjectAddTarget.cmake")

# target platfrom
if (ANDROID)
    include ("${PROJECT_CONFIGURE_CMAKE_EXT_DIR}/TargetPlatform/Android.cmake")
elseif (WIN32 OR MINGW)
    include ("${PROJECT_CONFIGURE_CMAKE_EXT_DIR}/TargetPlatform/Windows.cmake")
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
    include ("${PROJECT_CONFIGURE_CMAKE_EXT_DIR}/TargetPlatform/Linux.cmake")
endif ()

# compiler
if (MSVC)
    include ("${PROJECT_CONFIGURE_CMAKE_EXT_DIR}/Compiler/MSVC.cmake")
elseif (${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang" OR ${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
    include ("${PROJECT_CONFIGURE_CMAKE_EXT_DIR}/Compiler/Clang.cmake")
elseif (${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU")
    include ("${PROJECT_CONFIGURE_CMAKE_EXT_DIR}/Compiler/GCC.cmake")
endif ()


# ABI- CPU
# 统一CPU架构命名
macro (ATPBConvertTargetCPUABI OUTPUT_VAR ORIGIN_NAME)
    if(${ORIGIN_NAME} STREQUAL armv7 OR ${ORIGIN_NAME} STREQUAL armv7s OR ${ORIGIN_NAME} MATCHES "^armeabi(-v7a)?$")
        set(${OUTPUT_VAR} armv7)
    elseif(${ORIGIN_NAME} STREQUAL aarch64 OR ${ORIGIN_NAME} STREQUAL arm64-v8a OR ${ORIGIN_NAME} STREQUAL arm64)
        set (${OUTPUT_VAR} aarch64)
    elseif(${ORIGIN_NAME} STREQUAL x86 OR ${ORIGIN_NAME} STREQUAL i386 OR ${ORIGIN_NAME} STREQUAL i686)
        set (${OUTPUT_VAR} x86)
    elseif(${ORIGIN_NAME} STREQUAL x86_64 OR ${ORIGIN_NAME} STREQUAL AMD64 OR ${ORIGIN_NAME} STREQUAL x64)
        set (${OUTPUT_VAR} x86_64)
    elseif(${ORIGIN_NAME} STREQUAL mips)
        set (${OUTPUT_VAR} mips)
    elseif(${ORIGIN_NAME} STREQUAL mips64)
        set (${OUTPUT_VAR} mips64)
    else()
        message(FATAL_ERROR "Invalid ABI Name: ATPBConvertTargetCPUABI(${ORIGIN_NAME}).")
    endif()
endmacro ()

if (NOT PROJECT_ATFRAME_TARGET_CPU_ABI)
    if (ANDROID)
        ATPBConvertTargetCPUABI(PROJECT_ATFRAME_TARGET_CPU_ABI ${ANDROID_ABI})
    else ()
        if (CMAKE_OSX_ARCHITECTURES)
            ATPBConvertTargetCPUABI(PROJECT_ATFRAME_TARGET_CPU_ABI ${CMAKE_OSX_ARCHITECTURES})
        elseif (CMAKE_SYSTEM_PROCESSOR)
            ATPBConvertTargetCPUABI(PROJECT_ATFRAME_TARGET_CPU_ABI ${CMAKE_SYSTEM_PROCESSOR})
        else()
            ATPBConvertTargetCPUABI(PROJECT_ATFRAME_TARGET_CPU_ABI ${CMAKE_HOST_SYSTEM_PROCESSOR})
        endif()
    endif ()
endif ()

ATPBConvertTargetCPUABI(PROJECT_ATFRAME_HOST_CPU_ABI ${CMAKE_HOST_SYSTEM_PROCESSOR})

if(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL armv7)
    message(STATUS "Project Target CPU ABI: ${PROJECT_ATFRAME_TARGET_CPU_ABI}")
    message(STATUS "Project Host   CPU ABI: ${PROJECT_ATFRAME_HOST_CPU_ABI}")
elseif(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL aarch64)
    message(STATUS "Project Target CPU ABI: ${PROJECT_ATFRAME_TARGET_CPU_ABI}")
    message(STATUS "Project Host   CPU ABI: ${PROJECT_ATFRAME_HOST_CPU_ABI}")
elseif(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL x86)
    message(STATUS "Project Target CPU ABI: ${PROJECT_ATFRAME_TARGET_CPU_ABI}")
    message(STATUS "Project Host   CPU ABI: ${PROJECT_ATFRAME_HOST_CPU_ABI}")
elseif(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL x86_64)
    message(STATUS "Project Target CPU ABI: ${PROJECT_ATFRAME_TARGET_CPU_ABI}")
    message(STATUS "Project Host   CPU ABI: ${PROJECT_ATFRAME_HOST_CPU_ABI}")
elseif(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL mips)
    message(STATUS "Project Target CPU ABI: ${PROJECT_ATFRAME_TARGET_CPU_ABI}")
    message(STATUS "Project Host   CPU ABI: ${PROJECT_ATFRAME_HOST_CPU_ABI}")
elseif(PROJECT_ATFRAME_TARGET_CPU_ABI STREQUAL mips64)
    message(STATUS "Project Target CPU ABI: ${PROJECT_ATFRAME_TARGET_CPU_ABI}")
    message(STATUS "Project Host   CPU ABI: ${PROJECT_ATFRAME_HOST_CPU_ABI}")
else()
    message(FATAL_ERROR "Invalid Project CPU ABI: ${PROJECT_ATFRAME_TARGET_CPU_ABI}.")
endif()

include ("${PROJECT_CONFIGURE_CMAKE_EXT_DIR}/TargetCPUABI/${PROJECT_ATFRAME_TARGET_CPU_ABI}.cmake")
