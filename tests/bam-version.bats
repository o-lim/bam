#!/usr/bin/env bats

set -o pipefail

setup() {
  export MANWIDTH=80
  export BAM_OUTPUT_DIR="out"
}

before_each() {
  rm -rf out .tmp*
}

after_each() {
  rm -rf out .tmp*
}

@test "'bam version --help' displays help" {
  function expected() {
    cat << EOF
BAM-VERSION(1)                    Bam Manual                    BAM-VERSION(1)



NAME
       bam-version - Print the bam version

SYNOPSIS
       bam version [-h|--help]

DESCRIPTION
       Prints the bam version.

OPTIONS
       -h, --help
              Display this help and exit.



Bam $BAM_VERSION                                                BAM-VERSION(1)
EOF
  }
  LC_ALL=C bam version --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam version -h' is the same as 'bam version --help'" {
  bam version -h | diff -u <(bam version --help) -
}

@test "'bam help version' is the same as 'bam version --help'" {
  bam help version | diff -u <(bam version --help) -
}

@test "'bam version' displays the bam version" {
  run bam version

  diff -u <(echo "$BAM_VERSION") <(echo "${lines[@]}")
  [ "$status" -eq 0 ]
}
