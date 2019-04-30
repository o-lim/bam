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

@test "'bam ninja --help' displays help" {
  function expected() {
    cat << EOF
BAM-NINJA(1)                      Bam Manual                      BAM-NINJA(1)



NAME
       bam-ninja - Build a target or list of targets using Ninja

SYNOPSIS
       bam ninja [-h|--help] [-f <file>] [-j <N>] [-k <N>] [-l <N>] [-n]
                 [-v] [-d <mode>] [-t <tool>] [-w <flag>] [<targets...>]

DESCRIPTION
       Build targets using the Ninja build system. If targets are unspeci-
       fied, builds the 'default' target.

OPTIONS
       -h, --help
              Display this help and exit.

       -f <file>
              Specify input build file [default=build.ninja]

       -j <N> Run N jobs in parallel. The default is derived from the number
              of CPUs available.

       -k <N> Keep going until N jobs fail [default=1]

       -l <N> Do not start new jobs if the load average is greater than N

       -n     Dry run (don't run commands but act like they succeeded)

       -v     Show all command lines while building

       -d <mode>
              Enable debugging (use -d list to list modes)

       -t <tool>
              Run a subtool (use -t list to list subtools)

       -w <flag>
              Adjust warnings (use -w list to list warnings)

EOF
  }
  LC_ALL=C bam ninja --help | col -bx | sed -e '/^INTRODUCTION/,$d' | diff -Bbu <(expected) -
}

@test "'bam ninja -h' is the same as 'bam ninja --help'" {
  bam ninja -h | diff -u <(bam ninja --help) -
}

@test "'bam help ninja' is the same as 'bam ninja --help'" {
  bam help ninja | diff -u <(bam ninja --help) -
}

@test "'bam ninja' forwards to ninja and automatically calls gn first" {
  function expected() {
    echo "Generating JSON projects took XXms"
    echo "Generating compile_commands took XXms"
    echo "Done. Made XX targets from XX files in XXms"
    echo "ninja: Entering directory \`out'"
  }
  run bam ninja style

  diff -u <(expected) <(print_result | head -n 4 | sed -r 's/[0-9]+/XX/g')
  [ "$status" -eq 0 ]
}

@test "'bam -o <path> ninja' changes output dir" {
  gn gen .tmp1
  run bam -o .tmp1 ninja style

  diff -u <(echo "ninja: Entering directory \`.tmp1'") <(echo "${lines[3]}")
  [ "$status" -eq 0 ]
}

@test "'bam ninja' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  gn gen .tmp2
  run bam ninja style

  diff -u <(echo "ninja: Entering directory \`.tmp2'") <(echo "${lines[3]}")
  [ "$status" -eq 0 ]
}
