# 各项系统软件源

腾讯云源: https://mirrors.cloud.tencent.com/

## Msys2（需要使用MinGW64）

可选优先使用SNG的源，然后国内源，最后官方源:
```bash
echo "##
## MSYS2 repository mirrorlist
##

## Primary
## msys2.org
Server = http://mirrors.ustc.edu.cn/msys2/msys/\$arch
Server = https://mirrors.tuna.tsinghua.edu.cn/msys2/msys/\$arch
Server = http://mirror.bit.edu.cn/msys2/REPOS/MSYS2/\$arch
Server = http://mirrors.zju.edu.cn/msys2/msys2/REPOS/MSYS2/\$arch
Server = http://repo.msys2.org/msys/\$arch" > /etc/pacman.d/mirrorlist.msys ;

echo "##
##
## 32-bit Mingw-w64 repository mirrorlist
##

## Primary
## msys2.org
Server = http://mirrors.ustc.edu.cn/msys2/mingw/i686
Server = https://mirrors.tuna.tsinghua.edu.cn/msys2/mingw/i686
Server = http://mirror.bit.edu.cn/msys2/REPOS/MINGW/i686
Server = http://mirrors.zju.edu.cn/msys2/msys2/REPOS/MINGW/i686
Server = http://repo.msys2.org/mingw/i686" > /etc/pacman.d/mirrorlist.mingw32 ;

echo "##
## 64-bit Mingw-w64 repository mirrorlist
##

## Primary
## msys2.org
Server = http://mirrors.ustc.edu.cn/msys2/mingw/x86_64
Server = https://mirrors.tuna.tsinghua.edu.cn/msys2/mingw/x86_64
Server = http://mirror.bit.edu.cn/msys2/REPOS/MINGW/x86_64
Server = http://mirrors.zju.edu.cn/msys2/msys2/REPOS/MINGW/x86_64
Server = http://repo.msys2.org/mingw/x86_64" > /etc/pacman.d/mirrorlist.mingw64 ;
```

## WSL(Bash On Window)或Ubuntu

使用SNG的源:

```bash
if [ ! -e "/etc/apt/sources.list.bak" ]; then
  mv -f /etc/apt/sources.list /etc/apt/sources.list.bak ;
fi
echo "
deb http://mirror-sng.oa.com/ubuntu/ xenial main restricted universe multiverse
deb http://mirror-sng.oa.com/ubuntu/ xenial-security main restricted universe multiverse
deb http://mirror-sng.oa.com/ubuntu/ xenial-updates main restricted universe multiverse
deb http://mirror-sng.oa.com/ubuntu/ xenial-proposed main restricted universe multiverse
deb http://mirror-sng.oa.com/ubuntu/ xenial-backports main restricted universe multiverse
deb-src http://mirror-sng.oa.com/ubuntu/ xenial main restricted universe multiverse
deb-src http://mirror-sng.oa.com/ubuntu/ xenial-security main restricted universe multiverse
deb-src http://mirror-sng.oa.com/ubuntu/ xenial-updates main restricted universe multiverse
deb-src http://mirror-sng.oa.com/ubuntu/ xenial-proposed main restricted universe multiverse
deb-src http://mirror-sng.oa.com/ubuntu/ xenial-backports main restricted universe multiverse
" > /etc/apt/sources.list;
```