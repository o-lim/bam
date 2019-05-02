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

@test "'bam clean --help' displays help" {
  function expected() {
    cat << EOF
BAM-CLEAN(1)                      Bam Manual                      BAM-CLEAN(1)



NAME
       bam-clean - Cleans the output directory

SYNOPSIS
       bam clean [-h|--help] [-v|--verbose] [-n|--dry-run]
                 [<targets...>|<target-patterns...>]
       bam clean -r <rules...>

DESCRIPTION
       When specified without any arguments, deletes the contents of the out-
       put directory except for args.gn and creates a Ninja build environment
       sufficient to regenerate the build.

       If <targets> is specified, removes the given targets and recursively
       all files built for them.

       If <target-patterns> is specified, removes targets based on the given
       target label pattern and recursively all files built for them.

OPTIONS
  -h, --help
      Display this help and exit.

  -r <rules>
      Removes all files built using the given rules.

  <targets>
      List of targets to clean.

  <target-patterns>
      List of target label patterns to clean.



Bam $BAM_VERSION                                                  BAM-CLEAN(1)
EOF
  }
  LC_ALL=C bam clean --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam clean -h' is the same as 'bam clean --help'" {
  bam clean -h | diff -u <(bam clean --help) -
}

@test "'bam help clean' is the same as 'bam clean --help'" {
  bam help clean | diff -u <(bam clean --help) -
}

@test "'bam clean <target>' forwards to ninja -t clean" {
  gn gen out
  ninja -C out style
  run bam clean style

  diff -u /dev/null <(find . -name '*.style')
  [ "$status" -eq 0 ]
}

@test "'bam clean <target-label>' cleans based on target label" {
  gn gen out
  ninja -C out style
  run bam clean '//:style'

  diff -u /dev/null <(find . -name '*.style')
  [ "$status" -eq 0 ]
}

@test "'bam clean <target-label>' works outside source" {
  gn gen out
  ninja -C out style
  bam -C .. --source-root foobar -o foobar/out clean '//:style'
  diff -u /dev/null <(find . -name '*.style')
}

@test "'bam clean <target-pattern>' cleans based on target patterns" {
  gn gen out
  ninja -C out style foo bar
  run bam clean ':*'

  diff -u /dev/null <(find . -name '*.style')
  diff -u /dev/null <(find . -name '*.o')
  diff -u /dev/null <(find . -name '*.a')
  [ "$status" -eq 0 ]
}

@test "'bam clean <out-target-path>' cleans based on output target path" {
  gn gen out
  ninja -C out style foo bar
  run bam clean out/style/obj/src/*.style

  diff -u /dev/null <(find out/style/obj/src -name '*.style' --max-depth=1)
  [ "$status" -eq 0 ]
}

@test "'bam clean <target>' error if no ninja targets found" {
  function expected() {
    echo "bam-clean: error: cannot find any targets for 'fuzz'"
  }
  gn gen out
  run bam clean foo "fuzz"

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam clean <target-path>' error if no ninja targets found" {
  function expected() {
    echo "bam-clean: error: cannot find any targets for 'out/far'"
  }
  gn gen out
  run bam clean style "out/far"

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam clean <target^>' cleans target^" {
  function expected() {
    echo "bam-clean: found targets for 'src/foo.cxx^':"
    echo "    arm/obj/src/foo.cxx.o"
    echo "    mingw32/obj/src/foo.cxx.o"
    echo "    obj/src/foo.cxx.o"
    echo "    ut/obj/src/foo.cxx.o"
    echo "Cleaning..."
  }
  gn gen out --ide=json --json-file-name=build.json
  ninja -C out foo ut/foo_UT
  run bam clean -v src/foo.cxx^

  ! [ -e out/obj/src/foo.cxx.o ]
  ! [ -e out/arm/obj/src/foo.cxx.o ]
  ! [ -e out/mingw32/obj/src/foo.cxx.o ]
  ! [ -e out/ut/obj/src/foo.cxx.o ]
  diff -u <(expected) <(print_result | sed -n '1,/Cleaning/p')
  [ "$status" -eq 0 ]
}

@test "'bam clean <target(toolchain)^>' cleans target^ for toolchain only" {
  function expected() {
    echo "bam-clean: found targets for 'src/foo.cxx(//build/toolchain:x86)^':"
    echo "    obj/src/foo.cxx.o"
    echo "Cleaning..."
  }
  gn gen out --ide=json --json-file-name=build.json
  ninja -C out foo ut/foo_UT
  run bam clean -v 'src/foo.cxx(//build/toolchain:x86)^'

  ! [ -e out/obj/src/foo.cxx.o ]
  [ -f out/ut/obj/src/foo.cxx.o ]
  diff -u <(expected) <(print_result | sed -n '1,/Cleaning/p')
  [ "$status" -eq 0 ]
}

@test "'bam clean -r <rules>' forwards to ninja -t clean -r" {
  function expected() {
      echo "ninja: error: unknown rule 'myrule'"
  }
  gn gen out
  ninja -C out style

  diff -u <(expected) <(bam clean -r myrule 2>&1 > /dev/null)
}

@test "'bam clean' without args forwards to gn clean" {
  function expected() {
    echo "build.ninja"
    echo "build.ninja.d"
  }
  gn gen out
  run bam clean

  diff -u <(expected) <(ls -1 out)
  [ "$status" -eq 0 ]
}

@test "'bam clean' works outside source" {
  function expected() {
    echo "build.ninja"
    echo "build.ninja.d"
  }
  gn gen out

  bam -C .. --source-root foobar -o foobar/out clean
  diff -u <(expected) <(ls -1 out)
}

@test "'bam clean -v <target>' enables verbose" {
  function expected() {
    echo "4 files."
    echo "Cleaning..."
    echo "Remove obj/src/foo.cxx.o"
    echo "Remove obj/src/foo.stamp"
    echo "Remove obj/src/foo1.cpp.o"
    echo "Remove obj/src/foo2.cpp.o"
    echo "Target foo"
  }
  gn gen out
  ninja -C out foo
  run bam clean -v foo

  ! [ -e "out/obj/src/foo.cxx.o" ]
  diff -u <(expected) <(print_result | sort)
  [ "$status" -eq 0 ]
}

@test "'bam clean --verbose <target>' enables verbose" {
  function expected() {
    echo "Cleaning..."
    echo "Target baz"
    echo "0 files."
  }
  gn gen out
  run bam clean --verbose baz

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam clean --verbose' without targets enables verbose" {
  function expected() {
    echo "Got dotfile $(pwd)/.gn"
    echo "Using build dir //out/"
    echo "Using source root $(pwd)"
  }
  gn gen out
  ninja -C out foo
  run bam clean --verbose

  ! [ -e "out/obj/src/foo.cxx.o" ]
  diff -u <(/dev/null) <(print_result | sort | head -n -3)
  [ "$status" -eq 0 ]
}

@test "'bam clean -n <target>' enables dry-run" {
  function expected() {
    echo "4 files."
    echo "Cleaning..."
    echo "Remove obj/src/foo.cxx.o"
    echo "Remove obj/src/foo.stamp"
    echo "Remove obj/src/foo1.cpp.o"
    echo "Remove obj/src/foo2.cpp.o"
    echo "Target foo"
  }
  gn gen out
  ninja -C out foo
  run bam clean -n foo

  [ -f "out/obj/src/foo.cxx.o" ]
  diff -u <(expected) <(print_result | sort)
  [ "$status" -eq 0 ]
}

@test "'bam clean --dry-run <target>' enables dry-run" {
  function expected() {
    echo "2 files."
    echo "Cleaning..."
    echo "Remove libbaz.so"
    echo "Remove obj/src/baz.cpp.o"
    echo "Target baz"
  }
  gn gen out
  ninja -C out baz
  run bam clean --dry-run baz

  [ -f "out/libbaz.so" ]
  [ -f "out/obj/src/baz.cpp.o" ]
  diff -u <(expected) <(print_result | sort)
  [ "$status" -eq 0 ]
}

@test "'bam clean --dry-run' without targets enables dry-run" {
  function expected() {
    echo "Cleaning build dir out"
  }
  gn gen out
  ninja -C out foo
  run bam clean --dry-run

  ! [ -e "out/obj/src/foo.cxx.o" ]
  diff -u <(expected) <(print_result | sort)
  [ "$status" -eq 0 ]
}

@test "'bam -o <path> clean' changes output dir" {
  run bam -o .tmp1 clean ':style' ':lint'
  print_result | grep '\.tmp1'
  [ "$status" -eq 1 ]
}

@test "'bam clean' uses BAM_OUTPUT_DIR as default output dir" {
  export BAM_OUTPUT_DIR=".tmp2"
  run bam clean ':style' ':lint'
  print_result | grep '\.tmp2'
  [ "$status" -eq 1 ]
}
