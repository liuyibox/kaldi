#!/bin/bash

export DEVROOT=`xcode-select --print-path`
export SDKROOT=$DEVROOT/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk
 
# Set up relevant environment variables
export CPPFLAGS="-miphoneos-version-min=7.0 -arch armv7 -g -O3"
export CFLAGS="$CPPFLAGS -isysroot $SDKROOT"
export CXXFLAGS="$CFLAGS"

./configure \
    --prefix=`pwd`/../openfst \
    --disable-shared \
    --enable-static --disable-bin --enable-ngram-fsts --enable-lookahead-fsts CXX=`xcrun -sdk iphoneos -find clang` \
    LD=`xcrun -sdk iphoneos -find ld` --host=arm-apple-darwin

make -j 2
make install
