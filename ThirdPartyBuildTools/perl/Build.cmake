############################################################
#     Source: http://strawberryperl.com/releases.html      #
############################################################

find_package(Perl)
if (PERL_FOUND)
    set (PROJECT_3RD_PARTY_PERL_EXEC ${PERL_EXECUTABLE} CACHE FILEPATH "Perl executable path")
endif()

if(CMAKE_HOST_WIN32)
    if (PROJECT_3RD_PARTY_MSYS2_HOME AND EXISTS "${PROJECT_3RD_PARTY_MSYS2_HOME}/usr/bin/perl.exe")
        set (PROJECT_3RD_PARTY_PERL_MSYS2_EXEC "${PROJECT_3RD_PARTY_MSYS2_HOME}/usr/bin/perl.exe" CACHE FILEPATH "perl.exe")
        string(REPLACE "\\" "/" PROJECT_3RD_PARTY_PERL_MSYS2_EXEC ${PROJECT_3RD_PARTY_PERL_MSYS2_EXEC})
        set (PROJECT_3RD_PARTY_PERL_MINGW_EXEC "${PROJECT_3RD_PARTY_MSYS2_MINGW_HOME}/bin/perl.exe" CACHE FILEPATH "perl.exe")
        string(REPLACE "\\" "/" PROJECT_3RD_PARTY_PERL_MINGW_EXEC ${PROJECT_3RD_PARTY_PERL_MINGW_EXEC})
        if (NOT EXISTS ${PROJECT_3RD_PARTY_PERL_MINGW_EXEC})
            EchoWithColor(COLOR RED "Try to use pacman -S --noconfirm perl mingw-w64-x86_64-perl mingw-w64-i686-perl in msys2")
            message (FATAL_ERROR "Perl is required to build openssl")
        endif ()

        if (NOT PERL_FOUND)
            set (PERL_EXECUTABLE ${PROJECT_3RD_PARTY_PERL_MINGW_EXEC} CACHE FILEPATH "perl.exe" FORCE)
            set (PERL_FOUND YES CACHE BOOL "perl found" FORCE)
            set (PERL_VERSION_STRING "5.28.1.1" CACHE STRING "perl version" FORCE)

            set (PROJECT_3RD_PARTY_PERL_EXEC ${PERL_EXECUTABLE} CACHE FILEPATH "Perl executable path")
        endif ()
    endif()
endif ()

message (STATUS "Perl Executable: ${PERL_EXECUTABLE}")

if (NOT PERL_FOUND)
    if (WIN32)
        EchoWithColor(COLOR RED "Try to use pacman -S --noconfirm perl mingw-w64-x86_64-perl mingw-w64-i686-perl in msys2")
    elseif (APPLE)
        EchoWithColor(COLOR RED "It's recommanded to install perl with homebrew (https://brew.sh/) and using brew install perl.")
    elseif (UNIX)
        EchoWithColor(COLOR RED "Try to install perl with apt/yum/dnf install perl or pacman/yaourt -Syy --noconfirm perl?")
    endif ()
    message (FATAL_ERROR "Perl is required to build openssl")
endif ()
