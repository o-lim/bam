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

function print_result() {
  for line in "${lines[@]}"; do
    echo "$line"
  done
}

@test "'bam gn --help' displays help" {
  function expected() {
    cat << EOF
BAM-GN(1)                         Bam Manual                        BAM-GN(1)



NAME
       bam-gn - Meta-build system that generates Ninja build files

EOF
    build_gn_synopsis_quiet gn
    cat << EOF
                [--version]

DESCRIPTION
       This is a build system wrapper for gn.

       GN is a meta-build system that generates Ninja build files. It's meant
       to be faster and simpler than GYP. It outputs only Ninja build files.

       GN has an extensive built-in help system which provides a reference for
       every function and built-in variable. This page is more high-level.
       See "gn help" for more details.

EOF
    build_gn_options_common_quiet
    cat << EOF

       --version
              Prints the GN version number and exits.

EOF
  }
  LC_ALL=C bam gn --help | col -bx | sed -e '/^DESIGN PHILOSOPHY/,$d' | diff -Bbu <(expected) -
}

@test "'bam gn -h' is the same as 'bam gn --help'" {
  bam gn -h | diff -u <(bam gn --help) -
}

@test "'bam help gn' is the same as 'bam gn --help'" {
  bam help gn | diff -u <(bam gn --help) -
}

@test "'bam gn' forwards to gn and automatically calls gn first" {
  run bam gn gen

  [ -f "out/build.ninja" ]
  diff -u <(echo "Done. Made XX targets from XX files in XXms") <(echo "${lines[0]}" | sed -r 's/[0-9]+/XX/g')
  [ "$status" -eq 0 ]
}

@test "'bam gn' works outside source" {
  run bam -C .. --source-root foobar -o foobar/out gn gen

  [ -f "out/build.ninja" ]
  diff -u <(echo "Done. Made XX targets from XX files in XXms") <(echo "${lines[0]}" | sed -r 's/[0-9]+/XX/g')
  [ "$status" -eq 0 ]
}

@test "'bam -o <path> gn' changes output dir" {
  run bam -o .tmp1 gn gen

  [ -f ".tmp1/build.ninja" ]
  diff -u <(echo "Done. Made XX targets from XX files in XXms") <(echo "${lines[0]}" | sed -r 's/[0-9]+/XX/g')
  [ "$status" -eq 0 ]
}

@test "'bam gn' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam gn gen

  [ -f ".tmp2/build.ninja" ]
  diff -u <(echo "Done. Made XX targets from XX files in XXms") <(echo "${lines[0]}" | sed -r 's/[0-9]+/XX/g')
  [ "$status" -eq 0 ]
}
