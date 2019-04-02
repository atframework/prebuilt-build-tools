@echo off

chcp 65001

set CMAKE_GENERATOR=Visual Studio 15 2017

set CMAKE_GENERATOR_PLATFORM=x64

set SYSTEM_NAME=VS2017-x64

%~dp0/../BusyBox/busybox64.exe bash -i %~dp0/GenerateVSGo.sh -DPROJECT_ATFRAME_TARGET_CPU_ABI=x86_64

if %ERRORLEVEL% EQU 0 goto completed
if not defined NO_INTERACTIVE (
    pause
)

:completed
