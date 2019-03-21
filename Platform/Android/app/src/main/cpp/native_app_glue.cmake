set(APP_GLUE_DIR "${ANDROID_NDK}/sources/android/native_app_glue")
include_directories(${APP_GLUE_DIR})

# add_compiler_define(VK_USE_PLATFORM_ANDROID_KHR)
# add_linker_flags_for_runtime(-u ANativeActivity_onCreate)
add_definitions(-DVK_USE_PLATFORM_ANDROID_KHR)
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -u ANativeActivity_onCreate")

list (APPEND SOURCE_FILE_LIST "${APP_GLUE_DIR}/android_native_app_glue.c")