# Prebuilt Build Tools

## 已接入目录结构

+ ThirdParty                  : 第三方组件载入脚本，以后第三方组件也放这里，需要支持跨平台编译或跨平台预编译包
+ Platform:                   : 跨平台接入
  + Android                   : Android apk工程接入模板
+ ProjectConfig/CMake         : 用于工程配置的cmake脚本和模块
+ BuildTools : 生成工程文件的工具集

设置 **CMAKE_INSTALL_PREFIX** 变量后可以通过 ```cmake --build . --target install/make install/ninja install``` 来执行安装。
安装目标/lib(64)/cmake 内会有符合cmake标准模块规范的module文件

## 关于单元测试

编译完后再编译目录执行 ```ctest . -VV``` 即可。

## 工程工具

位于 [BuildTools](./) 目录下

Windows+MSVC: 直接点击对应的 ```GenerateVS*-*.bat``` 即可

Android: 需要先设置环境变量 ```ANDROID_NDK``` 、 ```JAVA_HOME``` 、```ANDROID_SDK``` 、```CMAKE_HOME``` 然后运行 ```GenerateAndroid*.*```


## 关于跨编译器：

+ 所有代码跨平台跨编译器
+ C++标准最高到C++17，兼容性要求如下:
  > * 【必须】AppleClang+libc++     ： 编译苹果平台只能这套工具链
  > * 【必须】clang+libc++          : Android的可选项 (高版本NDK默认这个)
  > * 【必须】clang+libstdc++       : Android的可选项
  > * 【必须】clang+libstdc++       : Android的可选项
  > * 【必须】gcc+libstdc++         : Android的可选项，服务器编译环境（必须兼容到 GCC 4.9）
  > * 【必须】gcc+STLport           : Android的可选项 (低版本NDK默认这个)
  > * 【可选】msvc+STLport          : 便于Windows下测试
  > 
  > 支持多个编译器和STL环境组合是为了方便后续客户端能够根据实际情况选择，包括但不限于包大小、其他组件也用同样的工具链

C++标准特性支持见: http://en.cppreference.com/w/cpp/compiler_support


目测静态检查的严格度 clang > msvc > gcc，所以最好是用clang编译。可以在mingw64或者unix like系统下生成工程的时候使用 ./cmake_dev.sh -us -c clang 或 ./cmake_dev.sh -us -c clang的绝对路径 来指定使用clang编译（前提是一定要安装了clang和libc++和libc++abi，clang也可以使用libstdc++，但对它的支持不是很好。）

# 注意事项
1. 在Windows中，动态链接库和可执行程序的堆再不同位置上，也就是说即便符号相同也不是同一个。所以导出接口不能跨动态库/exe管理内存。

# 开发环境
## Visual Studio 2017
  + .Net桌面开发(.net Framework 4.6-4.7)
  + C++桌面开发（cmake、vs2017(x86+x64)、MFC和ATL支持、C++/CLI、Clang/C2、Windows 10 SDK）
  + 使用C++的Linux开发
  + .net core跨平台开发(.net core 2.0)


## MSYS2-MinGW

安装包下载地址: http://mirrors.ustc.edu.cn/msys2/distrib/msys2-x86_64-latest.exe

### MSYS2-MinGW 32位环境

```bash
pacman -S curl wget tar vim zip unzip rsync openssh p7zip texinfo lzip m4 cmake m4 autoconf automake python git make tig perl mingw-w64-i686-perl mingw32/mingw-w64-i686-ninja mingw-w64-i686-toolchain mingw-w64-i686-libtool mingw-w64-i686-cmake mingw-w64-i686-extra-cmake-modules mingw32/mingw-w64-i686-clang mingw32/mingw-w64-i686-clang-analyzer mingw32/mingw-w64-i686-clang-tools-extra mingw32/mingw-w64-i686-compiler-rt mingw32/mingw-w64-i686-libc++ mingw32/mingw-w64-i686-libc++abi mingw-w64-i686-lld;
```

### MSYS2-MinGW 64位环境

```bash
pacman -S curl wget tar vim zip unzip rsync openssh p7zip texinfo lzip m4 cmake m4 autoconf automake python git make tig perl  mingw-w64-x86_64-perl mingw64/mingw-w64-x86_64-ninja mingw-w64-x86_64-toolchain mingw-w64-x86_64-libtool mingw-w64-x86_64-cmake mingw-w64-x86_64-extra-cmake-modules mingw64/mingw-w64-x86_64-compiler-rt mingw64/mingw-w64-x86_64-clang mingw64/mingw-w64-x86_64-clang-analyzer mingw64/mingw-w64-x86_64-clang-tools-extra mingw64/mingw-w64-x86_64-libc++ mingw64/mingw-w64-x86_64-libc++abi mingw-w64-x86_64-lld;
```

可选优先使用SNG的源，详情见: [REPO_SOURCE.md](REPO_SOURCE.md)

## WSL(Bash On Window)或Ubuntu
```bash
# 开发网可能需要设置代理
# export http_proxy=http://127.0.0.1:12759
# export https_proxy=http://127.0.0.1:12759
sudo apt update -y;
sudo apt install -y vim curl wget uuid-dev libuuid1 libcurl4-openssl-dev libssl-dev python3-setuptools python3-pip python3-mako perl automake gdb valgrind libncurses5-dev git unzip lunzip p7zip-full gcc cpp autoconf colorgcc telnet iotop htop g++ make libtool build-essential pkg-config;
wget "https://github.com/Kitware/CMake/releases/download/v3.13.4/cmake-3.13.4-Linux-x86_64.sh" -O cmake-Linux-x86_64.sh;
chmod +x cmake-Linux-x86_64.sh;
sudo ./cmake-Linux-x86_64.sh --skip-license --prefix=/usr ;

```

可选优先使用SNG的源，详情见: [Docs/REPO_SOURCE.md](Docs/REPO_SOURCE.md)

## ~~开发工具（尚未完成）~~

### 工具脚本
位于Tools目录下:

### 编译到ios或android库

[Tools/Build/build_android.sh](Tools/Build/build_android.sh) 用于编译android环境使用的.so库，请尽量使用静态链接的STL。这个脚本仅支持在Unix like系统下执行(macOS或Linux), Windows 可在git自带的bash里执行。

[Tools/Build/build_ios.sh](Tools/Build/build_ios.sh) 用于编译ios环境使用的.a库。默认会检测环境并使用最新版本的SDK，需要修改请参看-h的输出结果。

具体使用方式都可以使用-h参数查看，比如 ```./Tools/Build/build_android.sh -h``` 。

默认都会编译全架构(i386 x86_64 armv7 armv7s arm64/i386 x86_64 armv7 armv7s arm64)。不需要全架构也请参考-h的输出结果。

```bash
# 示例

./Tools/Build/build_android.sh -h                     # 查看帮助
./Tools/Build/build_android.sh -a "x86 armeabi armeabi-v7a arm64-v8a" -l 16 -t clang -c c++_static -n /mnt/d/workspace/lib/android/ndk/linux/android-ndk-r14b ;  # 编译android版本
cd -;

./Tools/Build/build_ios.sh -h                         # 查看帮助
 # 编译ios版本,bitcode选项: no
./Tools/Build/build_ios.sh -a "armv7 armv7s arm64" ;

# 编译ios版本,bitcode选项: all , 如果开启了bitcode，请增加-i all参数
./Tools/Build/build_ios.sh -a "armv7 armv7s arm64" -i all ;

# 请根据xcode里的配置选择是否需要开启bitcode
```
