
# if(CMAKE_SIZEOF_VOID_P MATCHES 8)
#     list (APPEND ATFRAME_TARGET_SYSTEM_LINK_NAMES
#         Ws2_64
#     )
# else ()
#     list (APPEND ATFRAME_TARGET_SYSTEM_LINK_NAMES
#         Ws2_32
#     )
# endif()

list (INSERT ATFRAME_TARGET_SYSTEM_LINK_NAMES 0
    Ws2_32 Dbghelp legacy_stdio_definitions iphlpapi Psapi
)
