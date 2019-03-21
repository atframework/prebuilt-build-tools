﻿unset (ATFRAME_TARGET_STATIC_LIBRARIES)
unset (ATFRAME_TARGET_STATIC_INCLUDE_DIRS)
unset (ATFRAME_TARGET_DYNAMIC_LIBRARIES)
unset (ATFRAME_TARGET_DYNAMIC_INCLUDE_DIRS)
unset (ATFRAME_TARGET_EXECUTABLE)
unset (ATFRAME_TARGET_COMMON_LINK_NAMES)
unset (ATFRAME_TARGET_SYSTEM_LINK_NAMES)

macro (ATPBTargetAddSubStaticLibrary)
    unset(SOURCE_FILE_LIST)
    unset(HEADER_FILE_LIST)
    unset(TARGET_LINK_NAMES)
    set (TARGET_NO_GLOBAL_INCLUDE OFF)
    set (TARGET_NO_GLOBAL_LINK OFF)

    if (${ARGC} GREATER 1)
        set (TARGET_NAME ${ARGV0})
        set (TARGET_PATH ${ARGV1})
    else ()
        set (TARGET_PATH ${ARGV0})
        get_filename_component(TARGET_NAME ${TARGET_PATH} NAME)
    endif ()

    foreach(arg IN LISTS ARGN)
        if (arg STRING_EQUAL "TARGET_NO_GLOBAL_INCLUDE")
            set (TARGET_NO_GLOBAL_INCLUDE ON)
        elseif (arg STRING_EQUAL "TARGET_NO_GLOBAL_LINK")
            set (TARGET_NO_GLOBAL_LINK ON)
        endif ()
    endforeach()

    EchoWithColor(COLOR GREEN "-- GSGame Static Library: ${TARGET_NAME}(${TARGET_PATH})")
    get_filename_component ("ATFRAME_TARGET_${TARGET_NAME}_DIR" ${TARGET_PATH} REALPATH CACHE)
    set ("ATFRAME_TARGET_${TARGET_NAME}_LINK_NAME" ${TARGET_NAME})
    
    file(RELATIVE_PATH TARGET_RELATIVE_ROOT_PATH ${PROJECT_SOURCE_DIR} ${ATFRAME_TARGET_${TARGET_NAME}_DIR})
    get_filename_component(TARGET_RELATIVE_ROOT_MODULE ${TARGET_RELATIVE_ROOT_PATH} DIRECTORY)
    add_subdirectory(${TARGET_PATH})
    set_property(TARGET ${TARGET_NAME} PROPERTY FOLDER ${TARGET_RELATIVE_ROOT_MODULE})

    if (NOT TARGET_NO_GLOBAL_INCLUDE)
        list(APPEND ATFRAME_TARGET_STATIC_LIBRARIES ${TARGET_NAME})
    endif ()
    if (NOT TARGET_NO_GLOBAL_LINK)
        list(APPEND ATFRAME_TARGET_STATIC_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_PATH}")
    endif ()

    unset(SOURCE_FILE_LIST)
    unset(HEADER_FILE_LIST)
    unset(TARGET_LINK_NAMES)
    unset(TARGET_NO_GLOBAL_INCLUDE)
    unset(TARGET_NO_GLOBAL_LINK)
    unset(TARGET_RELATIVE_ROOT_PATH)
    unset(TARGET_RELATIVE_ROOT_MODULE)
endmacro()


# Android 平台下，即便添加动态库，也会按静态库编译，然后最后一起添加到 android 的runtime的.so里去
macro (ATPBTargetAddSubDynamicLibrary)
    unset(SOURCE_FILE_LIST)
    unset(HEADER_FILE_LIST)
    unset(TARGET_LINK_NAMES)
    set (TARGET_NO_GLOBAL_INCLUDE OFF)
    set (TARGET_NO_GLOBAL_LINK OFF)

    if (${ARGC} GREATER 1)
        set (TARGET_NAME ${ARGV0})
        set (TARGET_PATH ${ARGV1})
    else ()
        set (TARGET_PATH ${ARGV0})
        get_filename_component(TARGET_NAME ${TARGET_PATH} NAME)
    endif ()

    foreach(arg IN LISTS ARGN)
        if (arg STRING_EQUAL "TARGET_NO_GLOBAL_INCLUDE")
            set (TARGET_NO_GLOBAL_INCLUDE ON)
        elseif (arg STRING_EQUAL "TARGET_NO_GLOBAL_LINK")
            set (TARGET_NO_GLOBAL_LINK ON)
        endif ()
    endforeach()

    EchoWithColor(COLOR GREEN "-- GSGame Dynamic Library: ${TARGET_NAME}(${TARGET_PATH})")
    get_filename_component ("ATFRAME_TARGET_${TARGET_NAME}_DIR" ${TARGET_PATH} REALPATH CACHE)
    set ("ATFRAME_TARGET_${TARGET_NAME}_LINK_NAME" ${TARGET_NAME})
    
    file(RELATIVE_PATH TARGET_RELATIVE_ROOT_PATH ${PROJECT_SOURCE_DIR} ${ATFRAME_TARGET_${TARGET_NAME}_DIR})
    get_filename_component(TARGET_RELATIVE_ROOT_MODULE ${TARGET_RELATIVE_ROOT_PATH} DIRECTORY)
    add_subdirectory(${TARGET_PATH})
    set_property(TARGET ${TARGET_NAME} PROPERTY FOLDER ${TARGET_RELATIVE_ROOT_MODULE})

    if (NOT TARGET_NO_GLOBAL_INCLUDE)
        list(APPEND ATFRAME_TARGET_DYNAMIC_LIBRARIES ${TARGET_NAME})
    endif ()
    if (NOT TARGET_NO_GLOBAL_LINK)
        list(APPEND ATFRAME_TARGET_DYNAMIC_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_PATH}")
    endif ()

    unset(SOURCE_FILE_LIST)
    unset(HEADER_FILE_LIST)
    unset(TARGET_LINK_NAMES)
    unset(TARGET_NO_GLOBAL_INCLUDE)
    unset(TARGET_NO_GLOBAL_LINK)
    unset(TARGET_RELATIVE_ROOT_PATH)
    unset(TARGET_RELATIVE_ROOT_MODULE)
endmacro()


macro (ATPBTargetAddSubExecutable)
    unset(SOURCE_FILE_LIST)
    unset(HEADER_FILE_LIST)
    unset(TARGET_LINK_NAMES)

    if (${ARGC} GREATER 1)
        set (TARGET_NAME ${ARGV0})
        set (TARGET_PATH ${ARGV1})
    else ()
        set (TARGET_PATH ${ARGV0})
        get_filename_component(TARGET_NAME ${TARGET_PATH} NAME)
    endif ()

    EchoWithColor(COLOR GREEN "-- GSGame Executable: ${TARGET_NAME}(${TARGET_PATH})")
    get_filename_component ("ATFRAME_TARGET_${TARGET_NAME}_DIR" ${TARGET_PATH} REALPATH CACHE)

    file(RELATIVE_PATH TARGET_RELATIVE_ROOT_PATH ${PROJECT_SOURCE_DIR} ${ATFRAME_TARGET_${TARGET_NAME}_DIR})
    get_filename_component(TARGET_RELATIVE_ROOT_MODULE ${TARGET_RELATIVE_ROOT_PATH} DIRECTORY)
    add_subdirectory(${TARGET_PATH})
    set_property(TARGET ${TARGET_NAME} PROPERTY FOLDER ${TARGET_RELATIVE_ROOT_MODULE})

    list(APPEND ATFRAME_TARGET_EXECUTABLE "${CMAKE_CURRENT_SOURCE_DIR}/${TARGET_NAME}")

    unset(SOURCE_FILE_LIST)
    unset(HEADER_FILE_LIST)
    unset(TARGET_LINK_NAMES)
    unset(TARGET_RELATIVE_ROOT_PATH)
    unset(TARGET_RELATIVE_ROOT_MODULE)
endmacro()

list(APPEND ATFRAME_TARGET_SYSTEM_LINK_NAMES ${COMPILER_OPTION_EXTERN_CXX_LIBS})

if (WIN32 OR CMAKE_HOST_WIN32)
    set(ATFRAME_MAKE_WRITABLE_COMMAND_PREFIX attrib -R /S /D)
elseif (UNIX OR MINGW OR CYGWIN OR APPLE OR CMAKE_HOST_APPLE OR CMAKE_HOST_UNIX)
    set(ATFRAME_MAKE_WRITABLE_COMMAND_PREFIX chmod -R +w)
endif()
function(ATPBMakeWritable)
    foreach(ARG IN LISTS ARGN)
        execute_process(COMMAND ${ATFRAME_MAKE_WRITABLE_COMMAND_PREFIX} ${ARG})
    endforeach()
endfunction()

function(ATPBMakeExecutable)
    if (UNIX OR MINGW OR CYGWIN OR APPLE OR CMAKE_HOST_APPLE OR CMAKE_HOST_UNIX)
        foreach(ARG IN LISTS ARGN)
            execute_process(COMMAND chmod -R +x ${ARG})
        endforeach()
    endif()
endfunction()

# 如果仅仅是设置环境变量的话可以用 ${CMAKE_COMMAND} -E env M4=/foo/bar 代替
macro (ATPBExpandListForCommandLine OUTPUT INPUT)
    foreach(ARG IN LISTS ${INPUT})
        string(REPLACE "\\" "\\\\" ATPBExpandListForCommandLine_OUT_VAR ${ARG})
        string(REPLACE "\"" "\\\"" ATPBExpandListForCommandLine_OUT_VAR ${ATPBExpandListForCommandLine_OUT_VAR})
        set (${OUTPUT} "${${OUTPUT}} \"${ATPBExpandListForCommandLine_OUT_VAR}\"")
        unset (ATPBExpandListForCommandLine_OUT_VAR)
    endforeach()
endmacro()