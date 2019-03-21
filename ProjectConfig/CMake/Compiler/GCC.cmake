
set (CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)
if(CMAKE_SIZEOF_VOID_P MATCHES 8)
    set(CMAKE_INSTALL_RPATH "lib64;../lib64;lib;../lib")
else ()
    set(CMAKE_INSTALL_RPATH "lib;../lib")
endif()
