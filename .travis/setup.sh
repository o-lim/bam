#!/bin/bash

set -eufo pipefail

source .travis/platform.sh

mkdir -p $HOME/bin

if [ "$PLATFORM" == "macosx" ]; then
  CC=clang
  CXX=clang++

  brew update
elif [ "$PLATFORM" == "cygwin" ]; then
  CC=gcc
  CXX=g++
elif [ "$PLATFORM" == "linux" ]; then
  CC=gcc
  CXX=g++

  sudo add-apt-repository ppa:ubuntu-toolchain-r/test -y
  sudo apt-get update -qq
  sudo apt-get install -qq autopoint gperf texinfo
  sudo apt-get install -qq gcc-4.9 g++-4.9 gcc-4.9-multilib g++-4.9-multilib libc6-dev-i386
  sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9
  sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30
  sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30
  sudo update-alternatives --set cc /usr/bin/gcc
  sudo update-alternatives --set c++ /usr/bin/g++
  sudo update-alternatives --set gcc /usr/bin/gcc-4.9
fi

echo "$CC --version" && $CC --version
echo "$CXX --version" && $CXX --version
echo "make --version" && make --version
