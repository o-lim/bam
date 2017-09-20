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

@test "'bam graph --help' displays help" {
  function expected() {
    cat << EOF
BAM-GRAPH(1)                      Bam Manual                      BAM-GRAPH(1)



NAME
       bam-graph - Output graphviz dotfile for targets

SYNOPSIS
       bam graph [-h|--help] [<targets...>]

DESCRIPTION
       Output a file in the syntax used by graphviz. If no target is given,
       generate a graph for all root targets. The output file is written to
       stdout.

OPTIONS
  -h, --help
      Display this help and exit.



Bam $BAM_VERSION                                                  BAM-GRAPH(1)
EOF
  }
  LC_ALL=C bam graph --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam graph -h' is the same as 'bam graph --help'" {
  bam graph -h | diff -u <(bam graph --help) -
}

@test "'bam help graph' is the same as 'bam graph --help'" {
  bam help graph | diff -u <(bam graph --help) -
}

@test "'bam graph' forwards to ninja -t graph" {
  gn gen out
  bam graph > out/graph.dot
  head -n 1 out/graph.dot | diff -u <(echo "digraph ninja {") -
}

@test "'bam -o <path> graph' changes output dir" {
  run bam -o .tmp1 graph style

  diff -u <(echo "ninja: fatal: chdir to '.tmp1' - No such file or directory") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}

@test "'bam graph' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam graph style

  diff -u <(echo "ninja: fatal: chdir to '.tmp2' - No such file or directory") <(echo "${lines[@]}")
  [ "$status" -eq 1 ]
}
