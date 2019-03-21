## 生成文档和导入配置

source_group_by_dir(SOURCE_FILE_LIST)
source_group_by_dir(HEADER_FILE_LIST)

include_directories(${ATFRAME_TARGET_STATIC_INCLUDE_DIRS} ${ATFRAME_TARGET_DYNAMIC_INCLUDE_DIRS})

add_executable(${TARGET_NAME} ${HEADER_FILE_LIST} ${SOURCE_FILE_LIST})
if (APPLE)
    set_target_properties(${TARGET_NAME} PROPERTIES BUNDLE TRUE)
endif()

target_link_libraries(${TARGET_NAME}
    ${ATFRAME_TARGET_DYNAMIC_LIBRARIES}
    ${ATFRAME_TARGET_STATIC_LIBRARIES}
    ${TARGET_LINK_NAMES}
    ${ATFRAME_TARGET_COMMON_LINK_NAMES}
    ${ATFRAME_TARGET_SYSTEM_LINK_NAMES}
)
