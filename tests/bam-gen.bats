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
  source ../bam-sh-test-setup
  rm -rf out .tmp*
}

after_each() {
  rm -rf out .tmp*
}

@test "'bam gen --help' displays help" {
  function expected() {
    cat << EOF
BAM-GEN(1)                        Bam Manual                        BAM-GEN(1)



NAME
       bam-gen - Generate ninja build files using 'gn gen'

EOF
    build_gn_synopsis_quiet "gen"
    cat << EOF

DESCRIPTION
       Generates ninja files from the current tree and puts them in the given
       output directory.

EOF
    build_gn_options_common_quiet
    cat << EOF



Bam $BAM_VERSION                                                    BAM-GEN(1)
EOF
  }
  LC_ALL=C bam gen --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam gen -h' is the same as 'bam gen --help'" {
  bam gen -h | diff -u <(bam gen --help) -
}

@test "'bam help gen' is the same as 'bam gen --help'" {
  bam help gen | diff -u <(bam gen --help) -
}

@test "'bam gen' forwards to gn gen and saves bam env" {
  run bam gen
  [ -f out/build.ninja ]
  [ -f out/.buildenv ]
  [ -f out/build-env.log ]
  [ "$status" -eq 0 ]
}

@test "'bam -o <path> gen' changes output dir" {
  run bam -o .tmp gen
  [ -f .tmp/build.ninja ]
  [ -f .tmp/.buildenv ]
  [ -f .tmp/build-env.log ]
  [ "$status" -eq 0 ]
}

@test "'bam gen' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp1"
  run bam gen
  [ -f .tmp1/build.ninja ]
  [ -f .tmp1/.buildenv ]
  [ -f .tmp1/build-env.log ]
  [ "$status" -eq 0 ]
}

@test "'bam gen' works outside source" {
  run bam -C .. --source-root foobar -o foobar/.tmp1 gen
  [ -f .tmp1/build.ninja ]
  [ -f .tmp1/.buildenv ]
  [ -f .tmp1/build-env.log ]
  [ "$status" -eq 0 ]
}
