cmake_minimum_required(VERSION 3.13.0)
cmake_policy(SET CMP0054 NEW)
#if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.13")
    cmake_policy(SET CMP0074 NEW)
#endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

enable_testing()

# get_filename_component(PROJECT_NAME ${CMAKE_CURRENT_LIST_DIR} NAME_WE)
set (PROJECT_NAME "PrebuiltBuildTools")

project(${PROJECT_NAME} C CXX ASM)

set("${PROJECT_NAME}_VERSION_MAJOR" "0")
set("${PROJECT_NAME}_VERSION_MINOR" "1")
set("${PROJECT_NAME}_VERSION_PATCH" "0")
set("${PROJECT_NAME}_VERSION" "${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH}")


# 准备下载依赖组件
include ("${CMAKE_CURRENT_LIST_DIR}/ThirdParty/libatframe_utils/libatframe_utils.prepare.cmake")

########################################################################
# CMake 模块 (递归包含模块, 带颜色输出模块, 平台检测模块)
set (PROJECT_CMAKE_MODULE_DIR "${ATFRAMEWORK_ATFRAME_UTILS_REPO_DIR}/project/cmake")
list(APPEND CMAKE_MODULE_PATH "${PROJECT_CMAKE_MODULE_DIR}/modules")


include("${PROJECT_CMAKE_MODULE_DIR}/modules/IncludeDirectoryRecurse.cmake")
include("${PROJECT_CMAKE_MODULE_DIR}/modules/EchoWithColor.cmake")
include("${PROJECT_CMAKE_MODULE_DIR}/modules/FindConfigurePackage.cmake")

include("${CMAKE_CURRENT_LIST_DIR}/ProjectConfig/CMake/ProjectBuildOption.cmake")
include("${PROJECT_CMAKE_MODULE_DIR}/FindPlatform.cmake")
include("${PROJECT_CMAKE_MODULE_DIR}/ProjectTools.cmake")


#####################################################################
# 导入编译器和编译选项配置
include("${PROJECT_CMAKE_MODULE_DIR}/CompilerOption.cmake")
include("${PROJECT_CMAKE_MODULE_DIR}/TargetOption.cmake")
EchoWithColor(COLOR GREEN "-- Build Type: ${CMAKE_BUILD_TYPE}")

########################################################################
# 导入项目配置和辅助函数
include("${CMAKE_CURRENT_LIST_DIR}/ProjectConfig/CMake/ProjectImportSetup.cmake")

if (PROJECT_ATFRAME_BUILD_THIRD_PARTY)
    add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/ThirdPartyBuildTools")
else ()
    ## 导入第三方库
    include("${CMAKE_CURRENT_LIST_DIR}/ThirdParty/ThirdParty.cmake")

    ## 内部工程全部采用更严格的选项
    if (COMPILER_STRICT_CFLAGS)
        add_definitions(${COMPILER_STRICT_CFLAGS})
    endif ()

    ## 默认隐藏符号，和Windows下MSVC保持一致
    if (${CMAKE_CXX_COMPILER_ID} STREQUAL "GNU" OR ${CMAKE_CXX_COMPILER_ID} STREQUAL "Clang" OR ${CMAKE_CXX_COMPILER_ID} STREQUAL "AppleClang")
        add_definitions(-fvisibility=hidden)
    endif ()

    ## 导入工程项目
    # ATPBTargetAddSubDynamicLibrary("src/...")


    ## 导入Sample项目
    # if (PROJECT_ENABLE_SAMPLE)
    #     add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/Sample")
    # endif()

    ## 导入单元测试项目
    # if (PROJECT_ENABLE_UNITTEST)
    #     include ("${ATFRAMEWORK_ATFRAME_UTILS_REPO_DIR}/test/test.utils-macro.cmake")
    #     ATPBTargetAddSubExecutable("${PROJECT_NAME}UnitTest" "TestSource")
    # endif()

    ## 导入工具项目
    # if (PROJECT_ENABLE_TOOLS)
    #     add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/Tools")
    # endif()


    #####################################################################
    # 导入平台支持
    if (ANDROID)
        add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/Platform/Android/app/src/main/cpp")
    endif ()

endif()