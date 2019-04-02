@echo off

chcp 65001

set CMAKE_GENERATOR=Visual Studio 15 2017

set CMAKE_GENERATOR_PLATFORM=ARM

set SYSTEM_NAME=VS2017-arm

%~dp0/../BusyBox/busybox64.exe bash -i %~dp0/GenerateVSGo.sh -DPROJECT_ATFRAME_TARGET_CPU_ABI=armv7

if %ERRORLEVEL% EQU 0 goto completed
if not defined NO_INTERACTIVE (
    pause
)

:completed
