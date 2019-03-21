@echo off

chcp 65001

if not defined BUILD_ROOT_PREFIX (
    set BUILD_ROOT_PREFIX=%~dp0
)

if not defined INSTALL_PREFIX (
    set INSTALL_PREFIX=%BUILD_ROOT_PREFIX%\VS2019-x86\Output
)

mkdir %BUILD_ROOT_PREFIX%\VS2019-x86

mkdir %INSTALL_PREFIX%

cd %BUILD_ROOT_PREFIX%\VS2019-x86

cmake -G "Visual Studio 16 2019" -A Win32 %~dp0\.. -DPROJECT_ATFRAME_TARGET_CPU_ABI=x86 -DCMAKE_INSTALL_PREFIX=%INSTALL_PREFIX%

if %ERRORLEVEL% EQU 0 goto completed
if not defined NO_INTERACTIVE (
    pause
)

:completed
