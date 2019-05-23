#!/bin/bash

SDKVERSION=$(xcrun -sdk iphoneos --show-sdk-version);
DEVELOPER_ROOT=$(xcode-select -print-path);
MAC_ARCHS="x86_64 arm64" ;                              # "i386 x86_64 armv7 armv7s arm64";
MAC_BITCODE=off ;                                       # off, all, bitcode, marker