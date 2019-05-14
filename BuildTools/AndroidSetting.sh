#!/bin/bash

ANDROID_TOOLCHAIN=clang ;               # clang, gcc
ANDROID_STL=gnustl_shared ;             # c++_static, c++_shared, gnustl_static, gnustl_shared
# ANDROID_ARCHS="armeabi-v7a arm64-v8a"; # "x86 x86_64 armeabi-v7a arm64-v8a";
ANDROID_ARCHS="arm64-v8a" ;
ANDROID_CPP_FEATURES="rtti exceptions" ;

ANDROID_COMPILE_SDK_VERSION=28;
ANDROID_MIN_SDK_VERSION=21;
ANDROID_TARGET_SDK_VERSION=28;
