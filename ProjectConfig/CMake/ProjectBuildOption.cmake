# 默认配置选项
#####################################################################

# libuv选项
set(LIBUV_ROOT "" CACHE STRING "libuv root directory")

# 测试配置选项
set(GTEST_ROOT "" CACHE STRING "GTest root directory")
set(BOOST_ROOT "" CACHE STRING "Boost root directory")
option(PROJECT_TEST_ENABLE_BOOST_UNIT_TEST "Enable boost unit test." OFF)
option(PROJECT_ENABLE_UNITTEST "Enable unit test" ON)

option(PROJECT_EXPORT_STATIC_LIB "Force to export static library." OFF)
option(ENABLE_NETWORK "Enable network support." OFF)
option(CRYPTO_DISABLED "Disable crypto module if not specify crypto lib." ON)
option(LOG_WRAPPER_ENABLE_LUA_SUPPORT "Enable lua support." OFF)
option(LOG_WRAPPER_CHECK_LUA "Check lua support." OFF)


# 工程选项
option(PROJECT_ATFRAME_BUILD_THIRD_PARTY "Just building third party prebuilt." ON)
option(PROJECT_ATFRAME_BUILD_THIRD_PARTY_BUSYBOX_MODE "Building third party prebuilt in busybox mode." OFF)

set(PROJECT_ATFRAME_TARGET_CPU_ABI "" CACHE STRING "Target CPU ABI(x86/x86_64/armv7/aarch64/mips/mips64)")