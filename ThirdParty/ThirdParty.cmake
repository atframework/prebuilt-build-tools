# include_macro_recurse(${CMAKE_CURRENT_LIST_DIR})

## 导入第三方工程
include("${CMAKE_CURRENT_LIST_DIR}/libatframe_utils/libatframe_utils.cmake")
add_subdirectory(${ATFRAMEWORK_ATFRAME_UTILS_REPO_DIR})
