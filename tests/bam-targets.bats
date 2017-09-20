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

@test "'bam targets --help' displays help" {
  function expected() {
    cat << EOF
BAM-TARGETS(1)                    Bam Manual                    BAM-TARGETS(1)



NAME
       bam-targets - List targets by their rule or depth in the DAG

SYNOPSIS
       bam targets (-h|--help)
       bam targets rule [<name>]
       bam targets depth [<N>]
       bam targets all

DESCRIPTION
       Output a list of targets either by rule or by depth. If no arguments
       are provided depth 1 is assumed.

OPTIONS
       -h, --help
              Display this help and exit.

       rule [<name>]
              Prints the list of targets using the given rule to be built. If
              no rule is given, it prints the source files (the leaves of the
              graph).

       depth [<N>]
              Prints the list of targets in a depth-first manner by the root
              targets (the ones with no outputs). Indentation is used to mark
              dependencies. If the depth is zero it prints all targets.

       all    Prints all the targets available without indentation and it is
              faster than the <depth> mode.



Bam $BAM_VERSION                                                BAM-TARGETS(1)
EOF
  }
  LC_ALL=C bam targets --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam targets -h' is the same as 'bam targets --help'" {
  bam targets -h | diff -u <(bam targets --help) -
}

@test "'bam help targets' is the same as 'bam targets --help'" {
  bam help targets | diff -u <(bam targets --help) -
}

@test "'bam targets' forwards to ninja -t targets" {
  gn gen out
  bam targets depth 0 | diff -u <(ninja -C out -t targets depth 0) -
  bam targets all | diff -u <(ninja -C out -t targets all) -
  bam targets rule | diff -u <(ninja -C out -t targets rule) -
}

@test "'bam -o <path> targets' changes output dir" {
  run bam -o .tmp1 targets

  diff -u <(echo "ninja: fatal: chdir to '.tmp1' - No such file or directory") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam targets' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam targets

  diff -u <(echo "ninja: fatal: chdir to '.tmp2' - No such file or directory") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}
