############################################################
#               Source: http://www.msys2.org/              #
#               choco install --yes msys2                  #
############################################################

list (APPEND MSYS2_HOME "C:/msys64" "C:/tools/msys64" "D:/msys64" "D:/tools/msys64")
foreach (TEST_DIR IN LISTS MSYS2_HOME )
    if (EXISTS "${TEST_DIR}/msys2_shell.cmd")
        set (PROJECT_3RD_PARTY_MSYS2_HOME ${TEST_DIR} CACHE PATH "msys2 install path")
        set (PROJECT_3RD_PARTY_MSYS2_SHELL "${TEST_DIR}/msys2_shell.cmd" CACHE FILEPATH "msys2 shell path")
        break()
    endif ()

endforeach ()

if (NOT PROJECT_3RD_PARTY_MSYS2_HOME)
    EchoWithColor(COLOR RED "Can not find MSYS2 in any of MSYS2_HOME: ${MSYS2_HOME}?")
    message (FATAL_ERROR "MSYS2 is required on Windows")
endif ()

set (PROJECT_3RD_PARTY_MSYS2_MINGW32_HOME "${PROJECT_3RD_PARTY_MSYS2_HOME}/mingw32" CACHE PATH "msys2-mingw32 home path")
set (PROJECT_3RD_PARTY_MSYS2_MINGW64_HOME "${PROJECT_3RD_PARTY_MSYS2_HOME}/mingw64" CACHE PATH "msys2-mingw32 home path")
set (PROJECT_3RD_PARTY_MSYS2_BASH "${PROJECT_3RD_PARTY_MSYS2_HOME}/msys2_shell.cmd" -msys2 -here -defterm -no-start)
set (PROJECT_3RD_PARTY_MSYS2_MINGW32_BASH "${PROJECT_3RD_PARTY_MSYS2_HOME}/msys2_shell.cmd" -mingw32 -here -defterm -no-start)
set (PROJECT_3RD_PARTY_MSYS2_MINGW64_BASH "${PROJECT_3RD_PARTY_MSYS2_HOME}/msys2_shell.cmd" -mingw64 -here -defterm -no-start)

if (${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL AMD64 OR ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL x86_64 OR ${CMAKE_HOST_SYSTEM_PROCESSOR} STREQUAL x64)
    set (PROJECT_3RD_PARTY_MSYS2_MINGW_BASH ${PROJECT_3RD_PARTY_MSYS2_MINGW64_BASH})
    set (PROJECT_3RD_PARTY_MSYS2_MINGW_HOME ${PROJECT_3RD_PARTY_MSYS2_MINGW64_HOME})
else ()
    set (PROJECT_3RD_PARTY_MSYS2_MINGW_BASH ${PROJECT_3RD_PARTY_MSYS2_MINGW32_BASH})
    set (PROJECT_3RD_PARTY_MSYS2_MINGW_HOME ${PROJECT_3RD_PARTY_MSYS2_MINGW32_HOME})
endif ()

if (NOT EXISTS "${PROJECT_3RD_PARTY_MSYS2_HOME}/usr/bin/make.exe")
    EchoWithColor(COLOR RED "Can not find make in MSYS2: ${PROJECT_3RD_PARTY_MSYS2_HOME}")
    message (FATAL_ERROR "Try to use pacman -S --noconfirm make to install it.")
endif ()