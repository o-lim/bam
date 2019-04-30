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

@test "'bam build --help' displays help" {
  function expected() {
    cat << EOF
BAM-BUILD(1)                      Bam Manual                      BAM-BUILD(1)



NAME
       bam-build - Build a target or list of targets

SYNOPSIS
       bam build [-h|--help] [-j <N>|--jobs <N>] [-l <N>|--load-average <N>]
                 [-k|--[no-]keep-going|-S|--stop] [-n|--dry-run]
                 [--check-up-to-date] [-v|--verbose]
                 [<targets...>|<target-patterns...>]

DESCRIPTION
       Build/Make the specified targets. If no targets are specified, builds
       the 'default' target.

OPTIONS
       -h, --help
              Display this help and exit.

       --check-up-to-date
              Do not perform a build, but merely check whether all specified
              targets are up-to-date. If so, the build completes successful-
              ly, as usual. However, if any files are out-of-date, instead of
              being built, an error is reported and the build fails. This op-
              tion may be useful to determine whether a build has been per-
              formed more recently than a source edit without incurring the
              cost of a build.

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

       -S, --no-keep-going, --stop
              Cancel the effect of the -k option.

       -v, --verbose
              Show all command lines while building.

       <targets>
              List of targets to build.

       <target-patterns>
              List of target label patterns to build.



Bam $BAM_VERSION                                                  BAM-BUILD(1)
EOF
  }
  LC_ALL=C bam build --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam build -h' is the same as 'bam build --help'" {
  bam build -h | diff -u <(bam build --help) -
}

@test "'bam help build' is the same as 'bam build --help'" {
  bam help build | diff -u <(bam build --help) -
}

@test "'bam build' forwards to ninja and automatically calls gn first" {
  function expected() {
    echo "Generating JSON projects took XXms"
    echo "Generating compile_commands took XXms"
    echo "Done. Made XX targets from XX files in XXms"
    echo "ninja: Entering directory \`out'"
  }
  run bam build style

  diff -u <(expected) <(print_result | head -n 4 | sed -r 's/[0-9]+/XX/g')
  [ -f out/compile_commands.json ]
  [ -f out/arm/compile_commands.json ]
  [ "$status" -eq 0 ]
}

@test "'bam build' automatically re-runs gn gen with --ide=json and --export-compile-commands-per-toolchain" {
  function expected() {
    echo "Generating JSON projects took XXms"
    echo "Generating compile_commands took XXms"
    echo "Done. Made XX targets from XX files in XXms"
    echo "ninja: Entering directory \`out'"
  }
  gn gen out
  run bam build foo

  diff -u <(expected) <(print_result | head -n 4 | sed -r 's/[0-9]+/XX/g')
  [ -f out/compile_commands.json ]
  [ -f out/arm/compile_commands.json ]
  [ "$status" -eq 0 ]
}

@test "'bam build <target>' forwards targets to ninja" {
  gn gen out
  run bam build foo

  diff -u <(echo "ninja: Entering directory \`out'") <(print_result | grep '^ninja:')
  diff -u <(echo "[4/4] STAMP obj/src/foo.stamp") <(print_result | tail -n 1)
  [ "$status" -eq 0 ]
}

@test "'bam build <target>' works outside source" {
  gn gen out
  run bam -C .. --source-root foobar -o foobar/out build foo

  diff -u <(echo "ninja: Entering directory \`foobar/out'") <(print_result | grep '^ninja:')
  diff -u <(echo "[4/4] STAMP obj/src/foo.stamp") <(print_result | tail -n 1)
  [ "$status" -eq 0 ]
}

@test "'bam build <target-pattern>' converts pattern to targets for ninja" {
  gn gen out
  run bam build "//:*(build/toolchain:style)"

  diff -u <(echo "ninja: Entering directory \`out'") <(print_result | grep '^ninja:')
  diff -u <(echo "[3/3] STAMP style/obj/style-headers.stamp") <(print_result | tail -n 1)
  [ "$status" -eq 0 ]
}

@test "'bam build <out-target-path>' converts output target paths to ninja target paths" {
  function expected() {
    echo "ninja: Entering directory \`out'"
    echo "[1/1] CXX obj/src/foo.cxx.o"
  }
  gn gen out
  run bam build out/obj/src/foo.cxx.o

  diff -u <(expected) <(print_result | sed '1,/^Done\./d')
  [ -f "out/obj/src/foo.cxx.o" ]
}

@test "'bam build <target^>' finds targets with rule containing target" {
  function expected() {
    echo "bam-build: found targets for 'src/foo.cxx^':"
    echo "    arm/obj/src/foo.cxx.o"
    echo "    mingw32/obj/src/foo.cxx.o"
    echo "    obj/src/foo.cxx.o"
    echo "    ut/obj/src/foo.cxx.o"
  }
  gn gen out --ide=json --json-file-name=build.json
  run bam build -v -n src/foo.cxx^

  diff -u <(expected) <(print_result | sed -n '/bam-build/,/bam-build/p' | head -n -1)
}

@test "'bam build <target(toolchain)^>' finds targets with rule containing target for toolchain only" {
  function expected() {
    echo "bam-build: found targets for 'src/foo.cxx(//build/toolchain:arm)^':"
    echo "    arm/obj/src/foo.cxx.o"
  }
  gn gen out --ide=json --json-file-name=build.json
  run bam build -v 'src/foo.cxx(//build/toolchain:arm)^'

  diff -u <(expected) <(print_result | sed -n '/bam-build/,/bam-build/p' | head -n -1)
  [ -f out/arm/obj/src/foo.cxx.o ]
  ! [ -e out/mingw32/obj/src/foo.cxx.o ]
  ! [ -e out/obj/src/foo.cxx.o ]
  ! [ -e out/ut/obj/src/foo.cxx.o ]
}

@test "'bam build <target> <target-pattern>' can take multiple targets/patterns" {
  gn gen out
  run bam build foo baz "//:style" "//src:bar(build/toolchain:arm)"

  diff -u <(echo "ninja: Entering directory \`out'") <(print_result | grep '^ninja:')
  [ -f "out//obj/src/foo.cxx.o" ]
  [ -f "out/libbaz.so" ]
  [ -f "out/arm/obj/src/libbar.a" ]
  [ -f "out/style/obj/include/bar.h.style" ]
  [ "$status" -eq 0 ]
}

@test "'bam build <target> <target-pattern>' error if no targets found" {
  function expected() {
    echo "bam-build: error: cannot find any targets for '//:fuzz'"
  }
  gn gen out
  run bam build foo baz "//:fuzz"

  diff -u <(expected) <(print_result | sed '1,/^Done\./d')
  [ "$status" -eq 1 ]
}

@test "'bam build <target>' error if no ninja targets found" {
  function expected() {
    echo "bam-build: error: cannot find any targets for 'fuzz'"
  }
  gn gen out
  run bam build foo "fuzz"

  diff -u <(expected) <(print_result | sed '1,/^Done\./d')
  [ "$status" -eq 1 ]
}

@test "'bam build <target-path>' error if no ninja targets found" {
  function expected() {
    echo "bam-build: error: cannot find any targets for 'out/far'"
  }
  gn gen out
  run bam build baz "out/far"

  diff -u <(expected) <(print_result | sed '1,/^Done\./d')
  [ "$status" -eq 1 ]
}

@test "'bam build -v' enables verbose" {
  function expected() {
    echo "bam-build: found targets for '//src:baz(build/toolchain:arm)':"
    echo "    arm/libbaz.so"
    echo "bam-build: building targets: arm/libbaz.so"
  }
  gn gen out
  run bam build -v '//src:baz(build/toolchain:arm)'

  [ -f "out/arm/libbaz.so" ]
  diff -u <(expected) <(print_result | sed '1,/^Done\./d' | head -n 3)
  print_result | grep '\[.*\] arm-none-eabi-g++'
  [ "$status" -eq 0 ]
}

@test "'bam build --verbose' enables verbose" {
  function expected() {
    echo "bam-build: building targets: foo"
  }
  gn gen out
  run bam build --verbose foo

  [ -f "out/obj/src/foo.cxx.o" ]
  diff -u <(expected) <(print_result | grep '^bam-build:' | head -n 1)
  print_result | grep '\[.*\] g++'
  [ "$status" -eq 0 ]
}

@test "'bam build -n' enables dry-run" {
  gn gen out
  run bam build -n foo

  ! [ -f "out/obj/src/foo.cxx.o" ]
  [ "$status" -eq 0 ]
}

@test "'bam build --dry-run' enables dry-run" {
  gn gen out
  run bam build --dry-run baz

  ! [ -e "out/libbaz.so" ]
  [ "$status" -eq 0 ]
}

@test "'bam -o <path> build' changes output dir" {
  gn gen .tmp1
  run bam -o .tmp1 build style

  diff -u <(echo "ninja: Entering directory \`.tmp1'") <(print_result | grep '^ninja:')
  [ "$status" -eq 0 ]
}

@test "'bam build' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  gn gen .tmp2
  run bam build style

  diff -u <(echo "ninja: Entering directory \`.tmp2'") <(print_result | grep '^ninja:')
  [ "$status" -eq 0 ]
}

@test "'bam build --check-up-to-date' passes for build up-to-date" {
  gn gen out
  ninja -C out src:foo
  sleep 1
  run bam build --check-up-to-date '//src:foo(//build/toolchain:x86)'

  diff -u <(echo) <(print_result | sed -e 's/^Done\. Made .*//' -e '/^Generating .*/d')
  [ "$status" -eq 0 ]
}

@test "'bam build --check-up-to-date' fails for build not up-to-date" {
  function expected() {
    echo "bam-build: error: build is out-of-date"
  }
  gn gen out
  sleep 1
  run bam build --check-up-to-date //src:foo

  diff -u <(expected) <(print_result | tail -n 1)
  [ "$status" -eq 1 ]
}
