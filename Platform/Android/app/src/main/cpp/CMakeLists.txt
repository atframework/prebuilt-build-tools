# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

# 源码
file(GLOB_RECURSE SOURCE_FILE_LIST 
    "${CMAKE_CURRENT_LIST_DIR}/*.h" "${CMAKE_CURRENT_LIST_DIR}/*.hpp")
file(GLOB_RECURSE HEADER_FILE_LIST 
    "${CMAKE_CURRENT_LIST_DIR}/*.c" "${CMAKE_CURRENT_LIST_DIR}/*.cpp" "${CMAKE_CURRENT_LIST_DIR}/*.cxx")

#source_group_by_dir(SOURCE_FILE_LIST)
#source_group_by_dir(HEADER_FILE_LIST)

include ("${CMAKE_CURRENT_LIST_DIR}/native_app_glue.cmake")

add_library(prebuiltbuildtools-runtime-lib

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ${SOURCE_FILE_LIST} ${HEADER_FILE_LIST})

# Searches for a specified prebuilt library and stores the path as a
# variable. Because CMake includes system libraries in the search path by
# default, you only need to specify the name of the public NDK library
# you want to add. CMake verifies that the library exists before
# completing its build.

find_library(ANDROID_NDK_LIB_LOG log)
find_library(ANDROID_NDK_LIB_ANDROID android)

# Links the target library to the log library
# included in the NDK.
list(APPEND ATFRAME_TARGET_SYSTEM_LINK_NAMES ${ANDROID_NATIVE_APP_GLUE} 
    ${ANDROID_NDK_LIB_LOG} ${ANDROID_NDK_LIB_ANDROID}
    # GLESv3 dl m z
)

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries(prebuiltbuildtools-runtime-lib
                       ${ATFRAME_TARGET_DYNAMIC_LIBRARIES}
                       ${ATFRAME_TARGET_STATIC_LIBRARIES}
                       ${ATFRAME_TARGET_COMMON_LINK_NAMES}
                       ${ATFRAME_TARGET_SYSTEM_LINK_NAMES}
)