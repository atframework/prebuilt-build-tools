@echo off

@mkdir build-for-win64

@cd build-for-win64

set PATH=%PATH%;C:\msys64\mingw64\bin

cmake -G "Visual Studio 16 2019" -A x64 .. -DCMAKE_FOLDER=ON -DCMAKE_INSTALL_PREFIX=%~dp0/build-for-win64/install-prefix

echo "���س���ʼ����Debug�汾��������ֱ�ӹص�"

pause

:: cmake --build . --config RelWithDebInfo -- "/m"

cmake --build . --config Debug -- "/m"

echo "���س���װ��Unity��������ֱ�ӹص�"

pause

cmake --build . --config Debug --target install

pause
