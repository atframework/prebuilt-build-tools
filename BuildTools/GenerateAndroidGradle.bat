@echo off

chcp 65001

cd %~dp0

BusyBox\busybox.exe bash GenerateAndroidGradle.sh

if %ERRORLEVEL% EQU 0 goto completed
if not defined NO_INTERACTIVE (
    pause
)

:completed
