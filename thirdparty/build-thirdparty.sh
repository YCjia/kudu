#!/bin/bash
# Copyright (c) 2012, Cloudera, inc.

set -x
set -e
TP_DIR=$(readlink -f $(dirname $BASH_SOURCE))

source $TP_DIR/vars.sh

################################################################################

if [ "$#" = "0" ]; then
  F_ALL=1
else
  # Allow passing specific libs to build on the command line
  for arg in "$*"; do
    case $arg in
      "cmake")      F_CMAKE=1 ;;
      "cyrus-sasl") F_CYRUS_SASL=1 ;;
      "gflags")     F_GFLAGS=1 ;;
      "glog")       F_GLOG=1 ;;
      "gperftools") F_GPERFTOOLS=1 ;;
      "gtest")      F_GTEST=1 ;;
      "libev")      F_LIBEV=1 ;;
      "lz4")        F_LZ4=1 ;;
      "protobuf")   F_PROTOBUF=1 ;;
      "snappy")     F_SNAPPY=1 ;;
      "zlib")       F_ZLIB=1 ;;
      *)            echo "Unknown module: $arg"; exit 1 ;;
    esac
  done
fi

################################################################################

# On some systems, autotools installs libraries to lib64 rather than lib.  Fix
# this by setting up lib64 as a symlink to lib.  We have to do this step first
# to handle cases where one third-party library depends on another.
mkdir -p "$PREFIX/lib"
ln -sf lib "$PREFIX/lib64"

# use the compiled tools
export PATH=$PREFIX/bin:$PATH

# build cmake
if [ -n "$F_ALL" -o -n "$F_CMAKE" ]; then
  cd $CMAKE_DIR
  ./bootstrap --prefix=$PREFIX --parallel=8
  make -j
  make install
fi

# build gflags
if [ -n "$F_ALL" -o -n "$F_GFLAGS" ]; then
  cd $GFLAGS_DIR
  ./configure --with-pic --prefix=$PREFIX
  make -j4 install
fi

# build glog
if [ -n "$F_ALL" -o -n "$F_GLOG" ]; then
  cd $GLOG_DIR
  ./configure --with-pic --prefix=$PREFIX --with-gflags=$PREFIX
  make -j4 install
fi

# build gperftools
if [ -n "$F_ALL" -o -n "$F_GPERFTOOLS" ]; then
  cd $GPERFTOOLS_DIR
  ./configure --enable-frame-pointers --with-pic --prefix=$PREFIX
  make -j4 install
fi

# build gtest
if [ -n "$F_ALL" -o -n "$F_GTEST" ]; then
  cd $GTEST_DIR
  cmake .
  make -j4
fi

# build protobuf
if [ -n "$F_ALL" -o -n "$F_PROTOBUF" ]; then
  cd $PROTOBUF_DIR
  ./configure --with-pic --disable-shared --prefix=$PREFIX
  make -j4 install
fi

# build snappy
if [ -n "$F_ALL" -o -n "$F_SNAPPY" ]; then
  cd $SNAPPY_DIR
  ./configure --with-pic --prefix=$PREFIX
  make -j4 install
fi

# build zlib
if [ -n "$F_ALL" -o -n "$F_ZLIB" ]; then
  cd $ZLIB_DIR
  ./configure --prefix=$PREFIX
  make -j4 install
fi

# build lz4
if [ -n "$F_ALL" -o -n "$F_LZ4" ]; then
  cd $LZ4_DIR
  $PREFIX/bin/cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX $LZ4_DIR
  make -j4 install
fi

## build libev
if [ -n "$F_ALL" -o -n "$F_LIBEV" ]; then
  cd $LIBEV_DIR
  ./configure --with-pic --disable-shared --prefix=$PREFIX
  make -j4 install
fi

## build cyrus-sasl
if [ -n "$F_ALL" -o -n "$F_CYRUS_SASL" ]; then
  cd $CYRUS_SASL_DIR
  [ -r Makefile ] && make distclean # (Jenkins was complaining about CFLAGS changes)
  # Disable everything except those protocols needed -- currently just Kerberos.
  # Sasl does not have a --with-pic configuration.
  CFLAGS="-fPIC -DPIC" CXXFLAGS="-fPIC -DPIC" ./configure \
    --disable-digest --disable-sql --disable-cram --disable-ldap --disable-otp \
    --enable-static --enable-staticdlopen --with-dblib=none --without-des \
    --prefix=$PREFIX
  make clean
  make # no -j4 ... concurrent build probs on RHEL?
  make install
fi

echo "---------------------"
echo "Thirdparty dependencies built and installed into $PREFIX successfully"
