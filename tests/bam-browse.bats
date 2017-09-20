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

@test "'bam browse --help' displays help" {
  function expected() {
    cat << EOF
BAM-BROWSE(1)                     Bam Manual                     BAM-BROWSE(1)



NAME
       bam-browse - Browse dependency graph in a web browser

SYNOPSIS
       bam browse [-h|--help]

DESCRIPTION
       Browse the dependency graph in a web browser. Clicking on a file
       focueses the view on that file, showing inputs and outputs. This fea-
       ture requires a Python installation.

OPTIONS
  -h, --help
      Display this help and exit.



Bam $BAM_VERSION                                                 BAM-BROWSE(1)
EOF
  }
  LC_ALL=C bam browse --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam browse -h' is the same as 'bam browse --help'" {
  bam browse -h | diff -u <(bam browse --help) -
}

@test "'bam help browse' is the same as 'bam browse --help'" {
  bam help browse | diff -u <(bam browse --help) -
}

@test "'bam -o <path> browse' changes output dir" {
  run bam -o .tmp1 browse

  diff -u <(echo "ninja: fatal: chdir to '.tmp1' - No such file or directory") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam browse' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam browse

  diff -u <(echo "ninja: fatal: chdir to '.tmp2' - No such file or directory") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}
