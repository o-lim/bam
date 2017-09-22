#!/usr/bin/env bash

export BAM_VERSION="0.0.0"
export BAM_CORE_PATH="$(pwd)"
export BAM_EXEC_PATH="$(pwd)/libexec"
export BAM_TEMPLATE_DIR="$(pwd)/templates"
export PATH="$(pwd)/bin:$PATH"

./configure --prefix=@prefix@
