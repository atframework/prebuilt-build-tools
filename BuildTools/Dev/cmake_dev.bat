@echo off

@mkdir build-for-win64

@cd build-for-win64

set PATH=%PATH%;C:\msys64\mingw64\bin

cmake -G "Visual Studio 16 2019" -A x64 .. -DCMAKE_FOLDER=ON -DCMAKE_INSTALL_PREFIX=%~dp0/build-for-win64/install-prefix

echo "按回车后开始编译Debug版本，否则请直接关掉"

pause

:: cmake --build . --config RelWithDebInfo -- "/m"

cmake --build . --config Debug -- "/m"

echo "按回车后安装到Unity，否则请直接关掉"

pause

cmake --build . --config Debug --target install

pause
