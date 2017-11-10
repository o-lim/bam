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
  rm -rf out
}

after_each() {
  rm -rf out
}

function print_result() {
  for line in "${lines[@]}"; do
    echo "$line"
  done
}

@test "'bam status --help' displays help" {
  function expected() {
    cat << EOF
BAM-STATUS(1)                     Bam Manual                     BAM-STATUS(1)



NAME
       bam-status - Show the build status

SYNOPSIS
       bam status [-h|--help] [-q|--quiet]
                  [--[no-]show-out-dir] [--[no-]show-source-root]
                  [<targets...>|<target-patterns...>]

DESCRIPTION
       Displays whether or not the build is up-to-date. If one or more tar-
       gets or target patterns are specified, then only display the build sta-
       tus of the matching targets.

       This command exits with an error if the build is not up-to-date. The
       exit codes are:

       0. The build is up-to-date.

       1. The build is out-of-date.

       2. Ninja files are out-of-date.

       3. Ninja files are out-of-date due to the build environment changing.

       4. There is no previously generated build.

       128. Unexpected error encountered.

OPTIONS
       -h, --help
              Display this help and exit.

       -q, --quiet
              Quiet mode. Do not print any output unless an error is encoun-
              tered.

       --show-out-dir
              Show \$BAM_OUTPUT_DIR if defined. Otherwise show the build out-
              put directory. The build output directory is always relative to
              the top-level directory, unless an absolute path is given.

       --no-show-out-dir
              Do not show the build output directory.

       --show-source-root
              Show the absolute path to the source root directory.

       --no-show-source-root
              Do not show the source root directory.

       <targets>
              List of targets to check status.

       <target-patterns>
              List of target label patterns to check status.



Bam $BAM_VERSION                                                 BAM-STATUS(1)
EOF
  }
  LC_ALL=C bam status --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam status -h' is the same as 'bam status --help'" {
  bam status -h | diff -u <(bam status --help) -
}

@test "'bam help status' is the same as 'bam status --help'" {
  bam help status | diff -u <(bam status --help) -
}

@test "'bam status --no-show-out-dir' does not show out dir" {
  function expected() {
    echo "No previously generated build"
  }
  BAM_OUTPUT_DIR=out run bam status --no-show-out-dir

  diff -u <(expected) <(print_result)
}

@test "'bam status --show-out-dir' still shows out dir" {
  function expected() {
    echo "Build output directory: //out"
    echo "No previously generated build"
  }
  BAM_OUTPUT_DIR=out run bam status --no-show-out-dir --show-out-dir

  diff -u <(expected) <(print_result)
}

@test "'bam status --show-source-root' shows source root" {
  function expected() {
    echo "Build output directory: //out"
    echo "Source root: $(pwd)"
    echo "No previously generated build"
  }
  BAM_OUTPUT_DIR=out run bam status --show-source-root

  diff -u <(expected) <(print_result)
}

@test "'bam status --no-show-source-root' does not show source root" {
  function expected() {
    echo "Build output directory: //out"
    echo "No previously generated build"
  }
  BAM_OUTPUT_DIR=out run bam status --show-source-root --no-show-source-root

  diff -u <(expected) <(print_result)
}

@test "'bam status' without running gen step" {
  function expected() {
    echo "Build output directory: //out"
    echo "No previously generated build"
  }
  BAM_OUTPUT_DIR=out run bam status

  diff -u <(expected) <(print_result)
  [ "$status" -eq 4 ]
}

@test "'bam status -q' without running gen step" {
  BAM_OUTPUT_DIR=out run bam status -q

  diff -u /dev/null <(print_result)
  [ "$status" -eq 4 ]
}

@test "'bam status' build environment changed" {
  function expected() {
    echo "Build output directory: //out"
    echo "Build environment modified"
    echo "Ninja files are out-of-date"
  }
  BAM_OUTPUT_DIR=out bam gen
  PKG_CONFIG_PATH="foobar" BAM_OUTPUT_DIR=out run bam status

  diff -u <(expected) <(print_result)
  [ "$status" -eq 3 ]
}

@test "'bam status --quiet' build environment changed" {
  BAM_OUTPUT_DIR=out bam gen
  PKG_CONFIG_PATH="foobar" BAM_OUTPUT_DIR=out run bam status --quiet

  diff -u /dev/null <(print_result)
  [ "$status" -eq 3 ]
}

@test "'bam status' gn file environment changed" {
  function expected() {
    echo "Build output directory: //out"
    echo "Build environment modified"
    echo "Ninja files are out-of-date"
  }
  BAM_OUTPUT_DIR=out bam gen
  HOME="/tmp" BAM_OUTPUT_DIR=out run bam status

  diff -u <(expected) <(print_result)
  [ "$status" -eq 3 ]
}

@test "'bam status -q' gn file environment changed" {
  BAM_OUTPUT_DIR=out bam gen
  HOME="/tmp" BAM_OUTPUT_DIR=out run bam status -q

  diff -u /dev/null <(print_result)
  [ "$status" -eq 3 ]
}

@test "'bam status' ninja files out-of-date" {
  function expected() {
    echo "Build output directory: //out"
    echo "Ninja files are out-of-date"
  }
  BAM_OUTPUT_DIR=out bam gen
  sleep 1
  touch .gn
  BAM_OUTPUT_DIR=out run bam status

  diff -u <(expected) <(print_result)
  [ "$status" -eq 2 ]
}

@test "'bam status -q' ninja files out-of-date" {
  BAM_OUTPUT_DIR=out bam gen
  sleep 1
  touch .gn
  BAM_OUTPUT_DIR=out run bam status -q

  diff -u /dev/null <(print_result)
  [ "$status" -eq 2 ]
}

@test "'bam status' have ninja files but not built" {
  function expected() {
    echo "Build output directory: //out"
    echo "Build is out-of-date"
  }
  BAM_OUTPUT_DIR=out bam gen
  BAM_OUTPUT_DIR=out run bam status

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam status -q' have ninja files but not built" {
  BAM_OUTPUT_DIR=out bam gen
  BAM_OUTPUT_DIR=out run bam status -q

  diff -u /dev/null <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam status' on up-to-date build" {
  function expected() {
    echo "Build output directory: //out"
    echo "Build is up-to-date"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=out bam status | diff <(expected) -
}

@test "'bam status -q' on up-to-date build" {
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=out bam status -q | diff /dev/null -
}

@test "'bam status <target-label>' error when no targets found" {
  function expected() {
    echo "Build output directory: //out"
    echo "bam-status: error: cannot find any targets for 'doesnotexist'"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=out run bam status 'doesnotexist'

  diff -u <(expected) <(print_result)
  [ "$status" -eq 128 ]
}

@test "'bam status -q <target-label>' error when no targets found" {
  function expected() {
    echo "bam-status: error: cannot find any targets for 'doesnotexist'"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=out run bam status -q 'doesnotexist'

  diff -u <(expected) <(print_result)
  [ "$status" -eq 128 ]
}

@test "'bam status <target-pattern>' gets status for specified targets only" {
  function expected_bar() {
    echo "Build output directory: //out"
    echo "Targets are up-to-date"
  }
  function expected_foobar() {
    echo "Build output directory: //out"
    echo "Targets are out-of-date"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  sleep 1
  touch src/foobar.cpp

  BAM_OUTPUT_DIR=out run bam status 'src:bar'
  diff -u <(expected_bar) <(print_result)
  [ "$status" -eq 0 ]

  BAM_OUTPUT_DIR=out run bam status 'src/*'
  diff -u <(expected_foobar) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam status <target-label>' on a single target when up-to-date" {
  function expected() {
    echo "Build output directory: //out"
    echo "Target is up-to-date"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=out run bam status 'src:foobar(//build/toolchain:ut)'
  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam status -q <target-label>' on a single target when up-to-date" {
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=out run bam status -q 'src:foobar(//build/toolchain:ut)'
  diff -u /dev/null <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam status <target-label>' on a single target when out-of-date" {
  function expected() {
    echo "Build output directory: //out"
    echo "Target is out-of-date"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  sleep 1
  touch src/bar.c
  BAM_OUTPUT_DIR=out run bam status 'src:bar(//build/toolchain:ut)'
  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam status -q <target-label>' on a single target when out-of-date" {
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  sleep 1
  touch src/bar.c
  BAM_OUTPUT_DIR=out run bam status -q 'src:bar(//build/toolchain:ut)'
  diff -u /dev/null <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam status <target^>' finds targets with rule containing target" {
  function expected() {
    echo "Build output directory: //out"
    echo "Targets are up-to-date"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=out run bam status 'src/bar.c^'
  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam status <target>' with bad ninja target fails" {
  function expected() {
    echo "Build output directory: //out"
    echo "bam-status: error: cannot find any targets for 'out/ut/doesnotexist'"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=out run bam status out/ut/doesnotexist
  diff -u <(expected) <(print_result)
  [ "$status" -eq 128 ]
}

@test "'bam status <target-path>' works for ninja targets" {
  function expected() {
    echo "Build output directory: //out"
    echo "Target is up-to-date"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=out run bam status out/ut/foobar_UT
  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam status <target>' works for ninja phony targets" {
  function expected() {
    echo "Build output directory: //out"
    echo "Target is up-to-date"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=out run bam status all
  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam status <targets>' works for multiple targets" {
  function expected() {
    echo "Build output directory: //out"
    echo "Targets are up-to-date"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=out run bam status out/ut/foobar_UT 'src:bar(//build/toolchain:ut)' test
  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam status <target-label>' works outside source root" {
  function expected() {
    echo "Build output directory: //out"
    echo "Target is up-to-date"
  }
  BAM_OUTPUT_DIR=out bam gen --args='platforms=["ut"] enable_lint=false'
  LD_LIBRARY_PATH="ut" ninja -C out
  BAM_OUTPUT_DIR=foobar/out run bam -C .. --source-root foobar status '//src:bar(//build/toolchain:ut)'
  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}
