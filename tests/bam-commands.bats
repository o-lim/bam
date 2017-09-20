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

@test "'bam commands --help' displays help" {
  function expected() {
    cat << EOF
BAM-COMMANDS(1)                   Bam Manual                   BAM-COMMANDS(1)



NAME
       bam-commands - List all commands required to rebuild given targets

SYNOPSIS
       bam commands [-h|--help] [<targets...>]

DESCRIPTION
       Given a list of targets, print a list of commands which, if executed in
       order, may be used to rebuild those targets, assuming that all output
       files are out of date.

OPTIONS
  -h, --help
      Display this help and exit.



Bam $BAM_VERSION                                               BAM-COMMANDS(1)
EOF
  }
  LC_ALL=C bam commands --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam commands -h' is the same as 'bam commands --help'" {
  bam commands -h | diff -u <(bam commands --help) -
}

@test "'bam help commands' is the same as 'bam commands --help'" {
  bam help commands | diff -u <(bam commands --help) -
}

@test "'bam commands' forwards to ninja -t commands" {
  gn gen out
  bam commands | diff -u <(ninja -C out -t commands) -
}

@test "'bam -o <path> commands' changes output dir" {
  run bam -o .tmp1 commands style

  diff -u <(echo "ninja: fatal: chdir to '.tmp1' - No such file or directory") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam commands' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam commands style

  diff -u <(echo "ninja: fatal: chdir to '.tmp2' - No such file or directory") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}
