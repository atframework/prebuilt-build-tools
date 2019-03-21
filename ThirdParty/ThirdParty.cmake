# include_macro_recurse(${CMAKE_CURRENT_LIST_DIR})

## 导入第三方工程
include("${CMAKE_CURRENT_LIST_DIR}/libatframe_utils/libatframe_utils.cmake")
add_subdirectory(${ATFRAMEWORK_ATFRAME_UTILS_REPO_DIR})

include("${CMAKE_CURRENT_LIST_DIR}/EASTL/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/ATI-AGS-Lib/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Common/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/CrashRpt/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/GameFileSystem/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/MemLeakChecker/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/PhyX/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/R302-NDA-developer/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/sfc/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/tag/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/perfy/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/Intel/import.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/directx/import.cmake")
