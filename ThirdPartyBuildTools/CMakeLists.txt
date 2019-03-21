
set (CMAKE_BUILD_TYPE "Release")
set (ATFRAME_THIRD_PARTY_BUILD_TOOLS_DIR ${CMAKE_CURRENT_LIST_DIR})

include ("${PROJECT_SOURCE_DIR}/ProjectConfig/CMake/ProjectThirdPartyTarget.cmake")

#############################################################################################################################
# 每一个第三方库都采用导入 【库名字】/Build.cmake 文件的形式, 然后在对应的 Build.cmake 里判定平台和写编译prebuilt的脚本
# 导入第三方库的 Build.cmake 文件统一采用 ATPBTargetAddThirdParty(PATH) 或 ATPBTargetAddThirdParty(NAME PATH) 的形式，相对于本文件目录
# *** 注意： Build.cmake 中设置的变量将全局可用
# *** 目前版本的预编译包会放在 ThirdParty/[库名字]/Prebuilt/[系统]-[CPU架构] 下

# Build.cmake 中的额外可用变量(用于统一外部工具链的编译选项):
# - CMAKE_C_FLAGS                               : C语言编译选项
# - CMAKE_CXX_FLAGS                             : C++编译选项
# - CMAKE_ASM_FLAGS                             : 汇编选项
# - 预编译包一般使用通用和release模式就可以了，其他的可能对MSVC有用
# - CMAKE_C_FLAGS_DEBUG                         : Debug模式C语言编译选项
# - CMAKE_C_FLAGS_RELEASE                       : Release模式C语言编译选项
# - CMAKE_C_FLAGS_RELWITHDEBINFO                : 带调试符号的Release模式C语言编译选项
# - CMAKE_C_FLAGS_MINSIZEREL                    : 最小尺寸C语言编译选项
# - CMAKE_CXX_FLAGS_DEBUG                       : Debug模式C++语言编译选项
# - CMAKE_CXX_FLAGS_RELEASE                     : Release模式C++语言编译选项
# - CMAKE_CXX_FLAGS_RELWITHDEBINFO              : 带调试符号的Release模式C++语言编译选项
# - CMAKE_CXX_FLAGS_MINSIZEREL                  : 最小尺寸C++语言编译选项
# - ---------------------------------------------------------------------
# - CMAKE_EXE_LINKER_FLAGS                      : 可执行程序链接选项
# - CMAKE_MODULE_LINKER_FLAGS                   : 模块链接选项
# - CMAKE_SHARED_LINKER_FLAGS                   : 共享库链接选项
# - CMAKE_STATIC_LINKER_FLAGS                   : 静态库链接选项
# - ---------------------------------------------------------------------
# - CMAKE_TOOLCHAIN_FILE                        : 工具链文件
# - CMAKE_C_COMPILER                            : C编译器路径
# - CMAKE_CXX_COMPILER                          : C++编译器路径
# - CMAKE_AR                                    : 汇编器路径
# - CMAKE_C_LINK_EXECUTABLE                     : C语言代码链接器规则
# - CMAKE_CXX_LINK_EXECUTABLE                   : C++语言代码链接器规则
# - CMAKE_C_COMPILER_LAUNCHER                   : C编译器启动器（用于接入ccache或distcc）
# - CMAKE_CXX_COMPILER_LAUNCHER                 : C++编译器启动器（用于接入ccache或distcc）
# - CMAKE_RANLIB                                : ranlib
# - CMAKE_HOST_SYSTEM_NAME                      : 宿主平台系统名称(Windows/Linux/Android/Darwin)
# - PROJECT_ATFRAME_HOST_CPU_ABI                     : 宿主平台的CPU结构(x86_/x86_64/armv7/aarch64/mips/mips64)
# - CMAKE_SYSTEM_NAME                           : 目标平台系统名称(Windows/Linux/Android/Darwin)
# - PROJECT_ATFRAME_TARGET_CPU_ABI                   : 目标平台的CPU结构(x86_/x86_64/armv7/aarch64/mips/mips64)
# - CMAKE_SYSROOT                               : 目标平台的根目录
# - CMAKE_SYSROOT_COMPILE                       : 目标平台的根目录
# - CMAKE_SYSTEM_LIBRARY_PATH                   : 额外的链接目录(# CMAKE_SYSTEM_LIBRARY_PATH ninja里解出的参数不对，原因未知，目前不要用这个)
# - ---------------------------------------------------------------------
# - ANDROID_TOOLCHAIN                           : Android NDK 的toolchain文件路径
# - ANDROID_NDK                                 : Android NDK 的路径
# - ANDROID_HOST_TAG                            : Android NDK 宿主机的tag(linux-x86_64/darwin-x86_64/windows-x86_64等)
# - ANDROID_HOST_PREBUILTS                      : Android NDK 宿主机的预编译文件路径(一般是 ${ANDROID_NDK}/prebuilt/${ANDROID_HOST_TAG})
# - ANDROID_TOOLCHAIN_ROOT                      : Android NDK 宿主机的toolchain路径
# - ANDROID_TOOLCHAIN_NAME                      : Android NDK 宿主机的toolchain名称（工具链前缀）
# - ANDROID_TOOLCHAIN_PREFIX                    : Android NDK 宿主机的toolchain工具前缀（一般是 ${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_NAME}-）
# - ANDROID_TOOLCHAIN_SUFFIX                    : Android NDK 宿主机的toolchain工具后缀（Windows下是 .exe）
# - ANDROID_ABI                                 : Android ABI (armeabi-v7a/arm64-v8a/x86/x86_64/mips/mips64)
# - ANDROID_PLATFORM                            : Android 平台(android-*)
# - ANDROID_PLATFORM_LEVEL                      : Android 平台ID(${ANDROID_PLATFORM}后面的数字部分)
# - ANDROID_STL                                 : Android STL库 (gnustl_static/gnustl_shared/c++_static/c++_shared//system/stlport_static/stlport_shared)
# - ANDROID_PIE                                 : Android目标是否开启位置无关性代码
# - ANDROID_CPP_FEATURES                        : Android目标功能(riit exceptions)
# - ANDROID_ALLOW_UNDEFINED_SYMBOLS             : Android目标是否允许未定义符号
# - ANDROID_ARM_MODE                            : Android mode (thumb/arm)
# - ANDROID_ARM_NEON                            : Android 是否启用NEON支持           
# - ANDROID_CCACHE                              : Android目标的ccache路径（不启用则是空）
# - ATFRAME_THIRD_PARTY_ANDROID_BUILD_CONFIG_SCRIPT  : Android的环境载入脚本
# - ATFRAME_THIRD_PARTY_ANDROID_BUILD_BASH           : bash 的路径
# - ---------------------------------------------------------------------
# - ATFRAME_THIRD_PARTY_INSTALL_PREFIX                   : 安装目录，一般为 ${PROJECT_SOURCE_DIR}/ThirdParty/【库名字】/Prebuilt/${CMAKE_SYSTEM_NAME}-${PROJECT_ATFRAME_TARGET_CPU_ABI}
# - ATFRAME_THIRD_PARTY_INC_DIR                          : 头文件目录，一般为 ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}/include
# - ATFRAME_THIRD_PARTY_LIB_DIR                          : 库文件目录，一般为 ${ATFRAME_THIRD_PARTY_INSTALL_PREFIX}/lib
# - ATFRAME_THIRD_PARTY_TARGET_NAME                      : 目标库名字
# - ATFRAME_THIRD_PARTY_TARGET_PATH                      : 目标库 Build.cmake文件所在路径
# - ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_PATH        : 目标库相对于工程根目录的路径
# - ATFRAME_THIRD_PARTY_TARGET_RELATIVE_ROOT_MODULE      : 目标库模块名
# - ATFRAME_THIRD_PARTY_TARGET_[大写库名字]_BUILD_DIR      : 目标库构建脚本所在目录 (会被导出且可以被其他模块读取)
# - ATFRAME_THIRD_PARTY_TARGET_[大写库名字]_INSTALL_PREFIX : 目标库安装目录 (会被导出且可以被其他模块读取)
# - ---------------------------------------------------------------------
# - PROJECT_3RD_PARTY_MSYS2_HOME                    : MSYS2安装目录
# - PROJECT_3RD_PARTY_MSYS2_SHELL                   : ${PROJECT_3RD_PARTY_MSYS2_HOME}/msys2_shell.cmd
# - PROJECT_3RD_PARTY_MSYS2_BASH                    : MSYS2 bash 入口
# - PROJECT_3RD_PARTY_MSYS2_MINGW32_BASH            : MSYS2-MinGW32 bash 入口
# - PROJECT_3RD_PARTY_MSYS2_MINGW64_BASH            : MSYS2-MinGW64 bash 入口
# - PROJECT_3RD_PARTY_MSYS2_MINGW_BASH              : MSYS2-MinGW 入口(64位系统等同于 ${PROJECT_3RD_PARTY_MSYS2_MINGW64_BASH} 否则 ${PROJECT_3RD_PARTY_MSYS2_MINGW32_BASH})
#############################################################################################################################

# 有些第三方库环境需要一些额外适配
include ("${CMAKE_CURRENT_LIST_DIR}/SetupCompactEnvs.cmake")

ATPBTargetAddThirdParty("perl")
ATPBTargetAddThirdParty("openssl")
ATPBTargetAddThirdParty("libcurl")
