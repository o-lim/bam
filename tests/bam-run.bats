#!/usr/bin/env bats

set -o pipefail

setup() {
  source bam-sh-test-setup
  export MANWIDTH=80
}

before_each() {
  export BAM_OUTPUT_DIR="out"
  cp -r ../examples .tmp
  cd .tmp/hello
  sed -i "s/host_platform = \"x86_64-linux-gnu\"/host_platform = \"x86_64-$(uname -s | tr A-Z a-z)-gnu\"/" build/config/BUILDCONFIG.gn
}

after_each() {
  cd ../..
  rm -rf .tmp*
}

function print_result() {
  for line in "${lines[@]}"; do
    echo "$line"
  done
}

@test "'bam run --help' displays help" {
  function expected() {
    cat << EOF
BAM-RUN(1)                        Bam Manual                        BAM-RUN(1)



NAME
       bam-run - Build and run a single target

SYNOPSIS
       bam run [-h|--help] [-j <N>|--jobs <N>] [-l <N>|--load-average <N>]
               [-k|--[no-]keep-going|-S|--stop] [-n|--dry-run]
               [--run-under <command-prefix>] [-v|--verbose]
               (<target>|<target-label>) [target-args...]

DESCRIPTION
       The bam run command is similar to bam build, except it is used to build
       and run a single target.

OPTIONS
       -h, --help
              Display this help and exit.

       -j <N>, --jobs <N>
              Run N jobs in parallel. The default is derived from the number
              of CPUs available.

       -k, --keep-going
              Continue as much as possible after an error. While a target
              that failed, and those that depend on it, cannot be remade, the
              other dependencies of these targets can be processed all the
              same.

       -l <N>, --load-average <N>
              Do not start new jobs if the load average is greater than N.

       -n, --dry-run
              Dry run (don't run commands but act like they succeeded).

       --run-under <command-prefix>
              This specifies a prefix that the target runner will insert in
              front of the command being executed. The <command-prefix> is
              split into words using Bourne shell tokenization rules, and then
              the list of words is prepended to the command that will be exe-
              cuted.

       -S, --no-keep-going, --stop
              Cancel the effect of the -k option.

       -v, --verbose
              Show all command lines while building.

       <target>
              The executable target to build and run.

       <target-label>
              The target label to build and run.



Bam $BAM_VERSION                                                    BAM-RUN(1)
EOF
  }
  LC_ALL=C bam run --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam run -h' is the same as 'bam run --help'" {
  bam run -h | diff -u <(bam run --help) -
}

@test "'bam help run' is the same as 'bam run --help'" {
  bam help run | diff -u <(bam run --help) -
}

@test "'bam run' without target generates error" {
  function expected() {
    echo "bam-run: error: missing executable target"
  }
  gn gen out
  run bam run

  diff -u <(expected) <(echo "${lines[0]}")
  [ "$status" -eq 1 ]
}

@test "'bam run' without output dir generates error" {
  function expected() {
    echo "bam-run: error: output directory 'out' does not contain a previously generated build"
  }
  run bam run foo

  diff -u <(expected) <(echo "${lines[0]}")
  [ "$status" -eq 1 ]
}

@test "'bam run' with multiple targets generates error" {
  function expected() {
    echo "bam-run: error: found multiple executable targets for '//*'"
    echo "    foo"
    echo "    hello"
  }
  echo 'Executable("foo") { sources = ["foo.cpp"]}' >> BUILD.gn
  gn gen out
  run bam run '//*'

  diff -u <(expected) <(print_result | tail -n +3)
  [ "$status" -eq 1 ]
}

@test "'bam run <target>' builds and runs target" {
  function expected() {
    echo "Hello World from SetText!!!"
    echo "Hello World from StaticText!!!"
  }
  gn gen out
  run bam run hello

  diff -u <(expected) <(print_result | tail -n 2)
  [ "$status" -eq 0 ]
}

@test "'bam run <target-label>' builds and runs target" {
  function expected() {
    echo "Hello World from SetText!!!"
    echo "Hello World from StaticText!!!"
  }
  gn gen out
  run bam run //src:hello

  diff -u <(expected) <(print_result | tail -n 2)
  [ "$status" -eq 0 ]
}

@test "'bam run <out-target-path>' builds and runs target" {
  function expected() {
    echo "Hello World from SetText!!!"
    echo "Hello World from StaticText!!!"
  }
  gn gen out
  run bam run out/hello

  diff -u <(expected) <(print_result | tail -n 2)
  [ "$status" -eq 0 ]
}

@test "'bam run <target-label>' works outside source" {
  function expected() {
    echo "Hello World from SetText!!!"
    echo "Hello World from StaticText!!!"
  }
  gn gen out
  run bam -C .. --source-root hello -o hello/out run //src:hello

  diff -u <(expected) <(print_result | tail -n 2)
  [ "$status" -eq 0 ]
}

@test "'bam run <target> --run-under <command-prefix>' runs target with command-prefix" {
  function expected() {
    echo "command: ./hello"
  }
  gn gen out
  run bam run --run-under 'echo command: ' hello

  diff -u <(expected) <(print_result | tail -n 1)
  [ "$status" -eq 0 ]
}

@test "'bam run <target> <args>' passes remaining args to the command" {
  function expected() {
    echo "command: ./hello arg1 arg2"
  }
  gn gen out
  run bam run --run-under 'echo command: ' hello arg1 arg2

  diff -u <(expected) <(print_result | tail -n 1)
  [ "$status" -eq 0 ]
}

@test "'bam run -v <target-label>' enables verbose" {
  function expectedHead() {
    echo "bam-run: found target for '//src:hello':"
    echo "    hello"
    echo "bam-run: building executable target 'hello'"
  }
  function expectedTail() {
    echo "Hello World from SetText!!!"
    echo "Hello World from StaticText!!!"
  }
  gn gen out
  run bam run -v //src:hello

  [ -f "out/hello" ]
  diff -u <(expectedHead) <(print_result | tail -n +3 | head -n 3)
  diff -u <(expectedTail) <(print_result | tail -n 2)
  print_result | grep '\[.*\] g++'
  [ "$status" -eq 0 ]
}

@test "'bam run -n <target-label>' enables dry-run" {
  function expected() {
    echo " ./hello"
  }
  gn gen out
  run bam run -n //src:hello

  ! [ -e "out/hello" ]
  diff -u <(expected) <(print_result | tail -n 1)
  [ "$status" -eq 0 ]
}

@test "'bam run --dry-run --verbose <target-label>' enables dry-run and verbose" {
  function expectedHead() {
    echo "bam-run: found target for '//src:hello':"
    echo "    hello"
    echo "bam-run: building executable target 'hello'"
  }
  function expectedTail() {
    echo "bam-run: running command line:  ./hello arg1 arg2"
    echo " ./hello \"arg1\" \"arg2\""
  }
  gn gen out
  run bam run --dry-run --verbose '//src:hello' "arg1" "arg2"

  ! [ -e "out/hello" ]
  diff -u <(expectedHead) <(print_result | tail -n +3 | head -n 3)
  diff -u <(expectedTail) <(print_result | tail -n 2)
  print_result | grep '\[.*\] g++'
  [ "$status" -eq 0 ]
}
