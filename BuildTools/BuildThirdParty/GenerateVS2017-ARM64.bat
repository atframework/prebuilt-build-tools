@echo off

chcp 65001

set CMAKE_GENERATOR=Visual Studio 15 2017

set CMAKE_GENERATOR_PLATFORM=ARM64

set SYSTEM_NAME=VS2017-arm64

%~dp0/../BusyBox/busybox64.exe bash -i %~dp0/GenerateVSGo.sh -DPROJECT_ATFRAME_TARGET_CPU_ABI=aarch64

if %ERRORLEVEL% EQU 0 goto completed
if not defined NO_INTERACTIVE (
    pause
)

:completed
