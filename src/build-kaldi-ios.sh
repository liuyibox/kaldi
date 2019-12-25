#!/bin/bash

# ios-configure runs a "configure" script using the iOS 4.3 SDK, generating a 
# static library that will load and run on your choice of iPhone, iPad, and 
# their respective simulators.
#
# Simply run in the same directory as a "configure" script.
# You can run this script for multiple targets and use lipo(1) to stitch them 
# together into a universal library.
# 
# Collected and maintained by Nolan Waite (nolan@nolanw.ca)
# 
# Magic compiler flags and incantations by Michael Aaron Safyan 
# (michaelsafyan@gmail.com). Generality by Christopher J. Stawarz
# (http://pseudogreen.org/bzr/sandbox/iphone/build_for_iphoneos)
# 

default_ios_version=10.3
default_min_ios_version=10.3
default_macosx_version=10.10

export IOS_VERSION="${IOS_VERSION:-$default_ios_version}"
export MIN_IOS_VERSION="${MIN_IOS_VERSION:-$default_min_ios_version}"
export MACOSX_VERSION="${MACOSX_VERSION:-$default_macosx_version}"

DEVELOPER=`xcode-select -print-path`

usage ()
{
  cat >&2 << EOF
Usage: ${0##*/} [-h] [-p prefix] target [configure_args]
  -h      Print help message
  -p      Installation prefix
          (default: `pwd`/build/[target]-[version])

The target must be one of "iphone", "ipad", or "simulator". Any additional 
arguments are passed to configure.

The following environment variables affect the build process:

  IOS_VERSION           (default: $default_ios_version)
  MIN_IOS_VERSION       (default: $default_min_ios_version)
  MACOSX_VERSION        (default: $default_macosx_version)

EOF
}

while getopts ":hp:t" opt; do
    case $opt in
        h  ) usage ; exit 0 ;;
        p  ) prefix="$OPTARG" ;;
        \? ) usage ; exit 2 ;;
    esac
done
shift $(( $OPTIND - 1 ))

if (( $# < 1 )); then
    usage
    exit 2
fi

target=$1
shift

case $target in
    iphone )
        arch=armv7
        platform=iPhoneOS
        host=arm-apple-darwin10
        ;;
    
    ipad )
        arch=armv7
        platform=iPhoneOS
        host=arm-apple-darwin10
        ;;
    
    simulator )
        arch=i686
        platform=iPhoneSimulator
        host=i686-apple-darwin10
        ;;
    * )
        usage
        exit 2
esac

export DEVROOT="/$DEVELOPER/Platforms/${platform}.platform/Developer"
export SDKROOT="$DEVROOT/SDKs/${platform}${IOS_VERSION}.sdk"
prefix="${prefix:-`pwd`/build/${target}-${IOS_VERSION}}"

if [ ! \( -d "$DEVROOT" \) ] ; then
   echo "The iPhone SDK could not be found. Folder \"$DEVROOT\" does not exist."
   exit 1
fi

if [ ! \( -d "$SDKROOT" \) ] ; then
   echo "The iPhone SDK could not be found. Folder \"$SDKROOT\" does not exist."
   exit 1
fi

if [ ! \( -x "./configure" \) ] ; then
    echo "This script must be run in the folder containing the \"configure\" script."
    exit 1
fi

export AR=`xcrun -sdk iphoneos -find ar`
export RANLIB=`xcrun -sdk iphoneos -find ranlib`
export CPP=`xcrun -sdk iphoneos -find clang`
export CC=`xcrun -sdk iphoneos -find clang`
export CXX=`xcrun -sdk iphoneos -find clang++`
export LD=`xcrun -sdk iphoneos -find ld`
export STRIP=`xcrun -sdk iphoneos -find strip`

export CPPFLAGS="-miphoneos-version-min=${MIN_IOS_VERSION}"
export CFLAGS="$CPPFLAGS -std=c++-11 -arch ${arch} -isysroot $SDKROOT"
export CXXFLAGS="$CPPFLAGS -arch ${arch} -isysroot $SDKROOT"
export LDFLAGS="-miphoneos-version-min=${MIN_IOS_VERSION} -arch ${arch} -isysroot $SDKROOT"

./configure --static --ios=true

make -j 2 online2
