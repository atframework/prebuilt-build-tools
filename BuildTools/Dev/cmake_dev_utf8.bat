@echo off

chcp 65001

REM @cd ..\Tables

REM python mtcore_prototable_copy.py

@cd ..\CoreNative

@mkdir build-job-msvc

@cd build-job-msvc

set PATH=%PATH%;C:\msys64\mingw64\bin

cmake -G "Visual Studio 15 2017 Win64" .. -DCMAKE_INSTALL_PREFIX=%~dp0/build_job_msvc64 -DPROJECT_TARGET_ROBOT_TARGET=%~dp0/../Client/Robot/Debug -DPROJECT_TARGET_UNITY_TARGET=%~dp0/../Client/UnityProject/Assets/Plugins/MtCore/Editor

echo "按回车后开始编译Debug版本，否则请直接关掉"

pause

:: cmake --build . --config RelWithDebInfo -- "/m"

cmake --build . --config Debug -- "/m"

echo "按回车后安装到Unity，否则请直接关掉"

pause

cmake --build . --config Debug --target install

pause