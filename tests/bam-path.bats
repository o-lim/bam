#!/usr/bin/env bats

set -o pipefail

setup() {
  source bam-sh-test-setup
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

function print_result() {
  for line in "${lines[@]}"; do
    echo "$line"
  done
}

@test "'bam path --help' displays help" {
  function expected() {
    cat << EOF
BAM-PATH(1)                       Bam Manual                       BAM-PATH(1)



NAME
       bam-path - Find paths between two targets

EOF
      build_gn_synopsis "path"
      cat << EOF
                [--all] [--public|--with-data] <target-one> <target-two>

DESCRIPTION
       Finds paths of dependencies between two targets.  Each unique path will
       be printed in one group, and groups will be separate by newlines.   The
       two  targets  can  appear in either order: paths will be found going in
       either direction.

       By default, a single path will be printed. If there is a path with on-
       ly public dependencies, the shortest public path will be printed. Oth-
       erwise, the shortest path using either public or  private  dependencies
       will be printed. If --with-data is specified, data deps will also be
       considered. If there are multiple shortest paths, an arbitrary one
       will be selected.

EOF
      build_gn_options_common
      cat << EOF

       --all  Prints  all  paths found rather than just the first one.  Public
              paths will be printed first in order of increasing length,  fol-
              lowed by non-public paths in order of increasing length.

       --public
              Considers only public paths.  Can't be used with --with-data.

       --with-data
              Additionally  follows data deps.  Without this flag, only public
              and private linked deps will be followed.  Can't  be  used  with
              --public.



Bam $BAM_VERSION                                                   BAM-PATH(1)
EOF
  }
  LC_ALL=C bam path --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam path -h' is the same as 'bam path --help'" {
  bam path -h | diff -u <(bam path --help) -
}

@test "'bam help path' is the same as 'bam path --help'" {
  bam help path | diff -u <(bam path --help) -
}

@test "'bam path' forwards to gn path" {
  function expected() {
    echo "No non-data paths found between these two targets."
  }
  gn gen out
  run bam path ':style' ':lint'

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam path' works outside source" {
  function expected() {
    echo "No non-data paths found between these two targets."
  }
  gn gen out
  run bam -C .. --source-root foobar -o foobar/out path '//:style' '//:lint'

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam -o <path> path' changes output dir" {
  run bam -o .tmp1 path ':style' ':lint'
  print_result | grep '\.tmp1'
  [ "$status" -eq 1 ]
}

@test "'bam path' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam path ':style' ':lint'
  print_result | grep '\.tmp2'
  [ "$status" -eq 1 ]
}
