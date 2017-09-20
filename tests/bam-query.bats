#!/usr/bin/env bats

set -o pipefail

setup() {
  export MANWIDTH=80
  cd foobar
}

teardown() {
  cd ..
}

before_each() {
  export BAM_OUTPUT_DIR="out"
  rm -rf out .tmp*
}

after_each() {
  rm -rf out .tmp*
}

@test "'bam query --help' displays help" {
  function expected() {
    cat << EOF
BAM-QUERY(1)                      Bam Manual                      BAM-QUERY(1)



NAME
       bam-query - Show inputs/outputs for a path

SYNOPSIS
       bam query [-h|--help] <target>

DESCRIPTION
       Dump the inputs and outputs of a given target.

OPTIONS
       -h, --help
              Display this help and exit.



Bam $BAM_VERSION                                                  BAM-QUERY(1)
EOF
  }
  LC_ALL=C bam query --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam query -h' is the same as 'bam query --help'" {
  bam query -h | diff -u <(bam query --help) -
}

@test "'bam help query' is the same as 'bam query --help'" {
  bam help query | diff -u <(bam query --help) -
}

@test "'bam query' forwards to ninja -t query" {
  gn gen out
  bam query style | diff -u <(ninja -C out -t query style) -
}

@test "'bam -o <path> query' changes output dir" {
  run bam -o .tmp1 query style

  diff -u <(echo "ninja: fatal: chdir to '.tmp1' - No such file or directory") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam query' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam query style

  diff -u <(echo "ninja: fatal: chdir to '.tmp2' - No such file or directory") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}
