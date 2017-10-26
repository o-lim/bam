#!/usr/bin/env bash

export BAM_TEST_ENV=1
export BAM_CORE_PATH="$(pwd)"
export BAM_EXEC_PATH="$(pwd)/libexec"
export PATH="$(pwd)/bin:$PATH"
export MANPATH="$(pwd)/man:$(man -w)"

./configure --prefix=@prefix@
