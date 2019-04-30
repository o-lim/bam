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

@test "'bam test --help' displays help" {
  function expected() {
    cat << EOF
BAM-TEST(1)                       Bam Manual                       BAM-TEST(1)



NAME
       bam-test - Build and run tests for one or more targets

SYNOPSIS
       bam test [-h|--help] [-j <N>|--jobs <N>] [-l <N>|--load-average <N>]
                [-k|--[no-]keep-going|-S|--stop] [-n|--dry-run]
                [--runs-per-test <N>] [--run-under <command-prefix>]
                [-r|--recursive] [--replace-test-args] [--test-arg <arg>]
                [--cache-results (yes|no|auto)] [--check-up-to-date]
                [--only <pattern>] [--skip <pattern>]
                [-v|--verbose] <target-patterns...>

DESCRIPTION
       The bam test command is similar to bam build, except it is used to
       build and run tests for one or more targets.

OPTIONS
       -h, --help
              Display this help and exit.

       --check-up-to-date
              Do not perform a build or run any tests, but merely check
              whether all specified tests are up-to-date. If there are any
              tests which have not been previously built or run, or whose test
              results are out-of-date, an error is reported and the test
              fails.

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

       --only <pattern>
              Only build and test the target labels matching the specified
              pattern.

       -r, --recursive
              Recursively build and run the tests for the specified targets as
              well as the tests for each of their dependencies.

       --replace-test-args
              If specified the default test arguments are replaced with those
              specified with --test-arg.

       --runs-per-test <N>
              Specifies the number of times each test should be executed.

       --run-under <command-prefix>
              This specifies a prefix that the test runner will insert in
              front of the test command being executed. The <command-prefix>
              is split into words using Bourne shell tokenization rules, and
              then the list of words is prepended to the command that will be
              executed.

       --skip <pattern>
              Do not build or test the target labels matching the specified
              pattern. (Note: skip targets take precedence over only targets)

       -S, --no-keep-going, --stop
              Cancel the effect of the -k option.

       -t (yes|no|auto), --cache-results (yes|no|auto)
              If set to 'auto' (the default) then only rerun a test if any of
              the following conditions apply:

              o A change is detected in the test or its dependencies

              o Multiple test runs were requested with --runs-per-test

              o The test failed

              If 'no', all tests will be executed unconditionally.

              If 'yes', the caching behavior will be the same as 'auto' except
              that it may cache results with --runs-per-test.

       --test-arg <arg>
              Passes command-line options/flags/arguments to the test (not to
              the test runner). This option can be used multiple times to
              pass several arguments (i.e. --test-arg=--logtostderr
              --test-arg=-v). By default, any specified test arguments are
              appended to the default set of test arguments. To replace the
              default arguments use --replace-test-args.

       -v, --verbose
              Show all command lines while building.

       <target-patterns>
              The target label patterns to build and test.



Bam $BAM_VERSION                                                   BAM-TEST(1)
EOF
  }
  LC_ALL=C bam test --help | col -bx | diff -Bbu <(expected) -
}

@test "'bam test -h' is the same as 'bam test --help'" {
  bam test -h | diff -u <(bam test --help) -
}

@test "'bam help test' is the same as 'bam test --help'" {
  bam help test | diff -u <(bam test --help) -
}

@test "'bam test' without output dir generates error" {
  function expected() {
    echo "bam-test: error: output directory 'out' does not contain a previously generated build"
  }
  run bam test foo

  diff -u <(expected) <(echo "${lines[0]}")
  [ "$status" -eq 1 ]
}

@test "'bam test --cache-results' detects invalid arguments" {
  function expected() {
    echo "bam-test: error: cache-results must be one of yes|no|auto"
  }
  gn gen out
  run bam test --cache-results foo

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam test -t' detects invalid arguments" {
  function expected() {
    echo "bam-test: error: cache-results must be one of yes|no|auto"
  }
  gn gen out
  run bam test -t foo

  diff -u <(expected) <(print_result)
  [ "$status" -eq 1 ]
}

@test "'bam test <target-label>' builds and runs tests for target" {
  function expected() {
    echo "[==========] Running 0 tests from 0 test cases."
    echo "[==========] 0 tests from 0 test cases ran."
    echo "[  PASSED  ] 0 tests."
  }
  gn gen out
  run bam test //src:foo --test-arg='--gtest_print_time=0'

  diff -u <(expected) <(print_result | tail -n 3)
  [ "$(print_result | grep -c 'Running main() from gtest_main.cc')" -eq 1 ]
  [ "$status" -eq 0 ]
}

@test "'bam test <target-label>' when no host target" {
  function expected() {
    echo "[==========] Running 0 tests from 0 test cases."
    echo "[==========] 0 tests from 0 test cases ran."
    echo "[  PASSED  ] 0 tests."
  }
  gn gen out --args='platforms=["ut"]'
  run bam test //src:foo --test-arg='--gtest_print_time=0'

  diff -u <(expected) <(print_result | tail -n 3)
  [ "$(print_result | grep -c 'Running main() from gtest_main.cc')" -eq 1 ]
  [ "$status" -eq 0 ]
}

@test "'bam test <target-label>' error when dependency name empty" {
  function expected() {
    echo "bam-test: error: ERROR This dependency name is empty"
  }
  gn gen out
  run bam test //

  diff -u <(expected) <(print_result | tail -n 1)
  [ "$status" -eq 1 ]
}

@test "'bam test <target-label>' error when target not found" {
  function expected() {
    echo "bam-test: error: cannot find any targets for '//foo(//build/toolchain:ut)'"
  }
  gn gen out
  run bam test //foo

  diff -u <(expected) <(print_result | tail -n 1)
  [ "$status" -eq 1 ]
}

@test "'bam test' does not test dependencies" {
  gn gen out
  LD_LIBRARY_PATH="./ut" run bam test //src:foobar

  [ "$(print_result | grep -c 'Running main() from gtest_main.cc')" -eq 1 ]
  [ "$status" -eq 0 ]
}

@test "'bam test --recursive' enables recursive" {
  gn gen out
  LD_LIBRARY_PATH="./ut" run bam test --recursive //src:foobar

  [ "$(print_result | grep -c 'Running main() from gtest_main.cc')" -eq 6 ]
  [ "$status" -eq 0 ]
}

@test "'bam test -r' enables recursive" {
  gn gen out
  LD_LIBRARY_PATH="./ut" run bam test -r //src:foobar

  [ "$(print_result | grep -c 'Running main() from gtest_main.cc')" -eq 6 ]
  [ "$status" -eq 0 ]
}

@test "'bam test <target-label>' builds and runs only specified target tests" {
  gn gen out
  LD_LIBRARY_PATH="./ut" run bam test //src:bar

  [ "$(print_result | grep -c 'Running main() from gtest_main.cc')" -eq 2 ]
  [ "$status" -eq 0 ]
}

@test "'bam test <target-pattern>' generates error if no test labels found" {
  function expected() {
    echo "bam-test: error: cannot find any tests for '//src/foo/*(//build/toolchain:ut)'"
  }
  gn gen out
  run bam test '//src/foo/*'

  diff -u <(expected) <(print_result | sed '1,/^Done\./d')
  [ "$status" -eq 1 ]
}

@test "'bam test <target-pattern>' generates error if no tests found" {
  function expected() {
    echo "bam-test: error: cannot find any tests for '//:*(//build/toolchain:ut)'"
  }
  gn gen out
  run bam test '//:*'

  diff -u <(expected) <(print_result | sed '1,/^Done\./d')
  [ "$status" -eq 1 ]
}

@test "'bam test' without arguments defaults to build and run all tests" {
  gn gen out
  LD_LIBRARY_PATH="./ut" run bam test

  [ "$(print_result | grep -c 'Running main() from gtest_main.cc')" -eq 6 ]
  [ "$status" -eq 0 ]
}

@test "'bam test --only' builds and runs only the specified matching tests" {
  gn gen out
  LD_LIBRARY_PATH="./ut" bam test '//src:bar' --only=bar_UT1
  [ -f "out/ut/obj/src/bar_bar_UT1.pass" ]
  ! [ -e "out/ut/obj/src/bar_bar_UT2.pass" ]
}

@test "'bam test --only' builds and runs only the specified matching test patterns" {
  gn gen out
  LD_LIBRARY_PATH="./ut" bam test '//src:bar' --only='bar.*UT2'
  ! [ -e "out/ut/obj/src/bar_bar_UT1.pass" ]
  [ -f "out/ut/obj/src/bar_bar_UT2.pass" ]
}

@test "'bam test --skip' does not build or run the specified matching tests" {
  gn gen out
  LD_LIBRARY_PATH="./ut" bam test '//src:bar' --skip=bar_UT1
  ! [ -e "out/ut/obj/src/bar_bar_UT1.pass" ]
  [ -f "out/ut/obj/src/bar_bar_UT2.pass" ]
}

@test "'bam test --skip' does not build or run the specified matching test patterns" {
  gn gen out
  LD_LIBRARY_PATH="./ut" bam test '//src:bar' --skip='bar.*UT2'
  [ -f "out/ut/obj/src/bar_bar_UT1.pass" ]
  ! [ -e "out/ut/obj/src/bar_bar_UT2.pass" ]
}

@test "'bam test --verbose' enables verbose" {
  function expectedHead() {
    echo "bam-test: found tests for '//src:*(//build/toolchain:ut)':"
    echo "    //src:bar_Test(//build/toolchain:ut)"
    echo "    //src:bar_gen_src_Test(//build/toolchain:ut)"
    echo "    //src:baz_Test(//build/toolchain:ut)"
    echo "    //src:foo_Test(//build/toolchain:ut)"
    echo "    //src:foobar_Test(//build/toolchain:ut)"
    echo "    //src:fu_Test(//build/toolchain:ut)"
    echo "    //src:fubar_Test(//build/toolchain:ut)"
    echo "bam-test: the following test groups were requested:"
    echo "    //src:bar_Test(//build/toolchain:ut)"
    echo "    //src:bar_gen_src_Test(//build/toolchain:ut)"
    echo "    //src:baz_Test(//build/toolchain:ut)"
    echo "    //src:foo_Test(//build/toolchain:ut)"
    echo "    //src:foobar_Test(//build/toolchain:ut)"
    echo "    //src:fu_Test(//build/toolchain:ut)"
    echo "    //src:fubar_Test(//build/toolchain:ut)"
    echo "bam-test: found these test labels:"
    echo "    //src:bar_bar_UT1(//build/toolchain:ut)"
    echo "    //src:bar_bar_UT2(//build/toolchain:ut)"
    echo "    //src:baz_UT(//build/toolchain:ut)"
    echo "    //src:foo_UT(//build/toolchain:ut)"
    echo "    //src:foobar_UT(//build/toolchain:ut)"
    echo "    //src:fu_UT(//build/toolchain:ut)"
    echo -n "bam-test: building test targets:"
    echo -n " ut/obj/src/bar_bar_UT1.pass"
    echo -n " ut/obj/src/bar_bar_UT2.pass"
    echo -n " ut/obj/src/baz_UT.pass"
    echo -n " ut/obj/src/foo_UT.pass"
    echo -n " ut/obj/src/foobar_UT.pass"
    echo    " ut/obj/src/fu_UT.pass"
  }
  gn gen out
  LD_LIBRARY_PATH="./ut" run bam test --verbose '//src:*'

  diff -u <(expectedHead) <(print_result | sed '1,/^Done\./d;/^ninja: Entering/,$d')
  print_result | grep -E '\[.*\] (clang|g)\+\+'
  [ "$status" -eq 0 ]
}

@test "'bam test -v' enables verbose" {
  function expectedHead() {
    echo "bam-test: found tests for '//src:foo(//build/toolchain:ut)':"
    echo "    //src:foo_Test(//build/toolchain:ut)"
    echo "bam-test: the following test groups were requested:"
    echo "    //src:foo_Test(//build/toolchain:ut)"
    echo "bam-test: found these test labels:"
    echo "    //src:foo_UT(//build/toolchain:ut)"
    echo "bam-test: building test targets: ut/foo_UT"
  }
  gn gen out
  run bam test -v --replace-test-args '//src:foo'

  diff -u <(expectedHead) <(print_result | sed '1,/^Done\./d;/^ninja: Entering/,$d')
  print_result | grep -E '\[.*\] (clang|g)\+\+'
  print_result | grep 'bam-test: running command-line: echo foo_pretest &&  ut/foo_UT'
  [ "$status" -eq 0 ]
}

@test "'bam test -v --only --skip' shows results of test filters" {
  function expectedHead() {
    echo "bam-test: found tests for '//src:*(//build/toolchain:ut)':"
    echo "    //src:bar_Test(//build/toolchain:ut)"
    echo "    //src:bar_gen_src_Test(//build/toolchain:ut)"
    echo "    //src:baz_Test(//build/toolchain:ut)"
    echo "    //src:foo_Test(//build/toolchain:ut)"
    echo "    //src:foobar_Test(//build/toolchain:ut)"
    echo "    //src:fu_Test(//build/toolchain:ut)"
    echo "    //src:fubar_Test(//build/toolchain:ut)"
    echo "bam-test: the following test groups were requested:"
    echo "    //src:bar_Test(//build/toolchain:ut)"
    echo "    //src:bar_gen_src_Test(//build/toolchain:ut)"
    echo "    //src:baz_Test(//build/toolchain:ut)"
    echo "    //src:foo_Test(//build/toolchain:ut)"
    echo "    //src:foobar_Test(//build/toolchain:ut)"
    echo "    //src:fu_Test(//build/toolchain:ut)"
    echo "    //src:fubar_Test(//build/toolchain:ut)"
    echo "bam-test: found these test labels:"
    echo "    //src:bar_bar_UT1(//build/toolchain:ut)"
    echo "    //src:bar_bar_UT2(//build/toolchain:ut)"
    echo "    //src:baz_UT(//build/toolchain:ut)"
    echo "    //src:foo_UT(//build/toolchain:ut)"
    echo "    //src:foobar_UT(//build/toolchain:ut)"
    echo "    //src:fu_UT(//build/toolchain:ut)"
    echo "bam-test: tests after applying skip filter 'foobar':"
    echo "    //src:bar_bar_UT1(//build/toolchain:ut)"
    echo "    //src:bar_bar_UT2(//build/toolchain:ut)"
    echo "    //src:baz_UT(//build/toolchain:ut)"
    echo "    //src:foo_UT(//build/toolchain:ut)"
    echo "    //src:fu_UT(//build/toolchain:ut)"
    echo "bam-test: tests after applying only filter 'bar':"
    echo "    //src:bar_bar_UT1(//build/toolchain:ut)"
    echo "    //src:bar_bar_UT2(//build/toolchain:ut)"
    echo -n "bam-test: building test targets:"
    echo -n " ut/obj/src/bar_bar_UT1.pass"
    echo    " ut/obj/src/bar_bar_UT2.pass"
  }
  gn gen out
  LD_LIBRARY_PATH="./ut" run bam test -v --only bar --skip foobar '//src:*'

  diff -u <(expectedHead) <(print_result | sed '1,/^Done\./d;/^ninja: Entering/,$d')
  print_result | grep -E '\[.*\] (clang|g)\+\+'
  [ "$status" -eq 0 ]
}
@test "'bam test --dry-run' enables dry-run" {
  function expected() {
    echo "echo foo_pretest &&  ut/foo_UT "
    echo "touch ut/obj/src/foo_UT.pass"
  }
  gn gen out
  run bam test --dry-run --replace-test-args '//src:foo'

  ! [ -e "out/ut/foo_UT" ]
  ! [ -e "out/ut/obj/src/foo_UT.pass" ]
  diff -u <(expected) <(print_result | tail -n 2)
  [ "$status" -eq 0 ]
}

@test "'bam test -n' enables dry-run" {
  gn gen out
  run bam test -n '//src:foo'

  ! [ -e "out/ut/foo_UT" ]
  ! [ -e "out/ut/obj/src/foo_UT.pass" ]
  [ "$status" -eq 0 ]
}

@test "'bam test --cache-results no' forces tests to run" {
  gn gen out
  ninja -C out src:foo_Test
  run bam test --cache-results no '//src:foo'

  print_result | grep -c 'Running main() from gtest_main.cc'
  [ "$status" -eq 0 ]
}

@test "'bam test --cache-results auto' does not re-run tests" {
  gn gen out
  ninja -C out src:foo_Test
  run bam test --cache-results auto '//src:foo'

  [ "$(print_result | grep -c 'Running main() from gtest_main.cc')" -eq 0 ]
  [ "$status" -eq 0 ]
}

@test "'bam test --cache-results yes' does not re-run tests" {
  gn gen out
  ninja -C out src:foo_Test
  run bam test --cache-results yes '//src:foo'

  [ "$(print_result | grep -c 'Running main() from gtest_main.cc')" -eq 0 ]
  [ "$status" -eq 0 ]
}

@test "'bam test --cache-results yes --runs-per-test N' caches for each pass" {
  gn gen out
  run bam test -n --cache-results yes --runs-per-test 2 '//src:foo'

  [ "$(print_result | grep -c 'touch ut/obj/src/foo_UT.pass')" -eq 2 ]
  [ "$status" -eq 0 ]
}

@test "'bam test -t no' forces tests to run" {
  gn gen out
  ninja -C out src:foo_Test
  run bam test -t no '//src:foo'

  print_result | grep -c 'Running main() from gtest_main.cc'
  [ "$status" -eq 0 ]
}

@test "'bam test -t auto' does not re-run tests" {
  gn gen out
  ninja -C out src:foo_Test
  run bam test -t auto '//src:foo'

  [ "$(print_result | grep -c 'Running main() from gtest_main.cc')" -eq 0 ]
  [ "$status" -eq 0 ]
}

@test "'bam test -t yes' does not re-run tests" {
  gn gen out
  ninja -C out src:foo_Test
  run bam test -t yes '//src:foo'

  [ "$(print_result | grep -c 'Running main() from gtest_main.cc')" -eq 0 ]
  [ "$status" -eq 0 ]
}

@test "'bam test -t yes --runs-per-test N' caches for each pass" {
  gn gen out
  run bam test -n -t yes --runs-per-test 2 '//src:foo'

  [ "$(print_result | grep -c 'touch ut/obj/src/foo_UT.pass')" -eq 2 ]
  [ "$status" -eq 0 ]
}

@test "'bam test' works outside source" {
  gn gen out
  ninja -C out src:foo_Test
  LD_LIBRARY_PATH="./ut" run bam -C .. --source-root foobar -o foobar/out test -t no

  print_result | grep -c 'Running main() from gtest_main.cc'
  [ "$status" -eq 0 ]
}

@test "'bam test <target-label>' works outside source" {
  gn gen out
  ninja -C out src:foo_Test
  run bam -C .. --source-root foobar -o foobar/out test -t no '//src:foo'

  print_result | grep -c 'Running main() from gtest_main.cc'
  [ "$status" -eq 0 ]
}

@test "'bam test --runs-per-test N' runs tests multiple times" {
  function expected() {
    echo "bam-test: running test 'ut/foo_UT' (1 of 2):"
    echo "bam-test: running test 'ut/foo_UT' (2 of 2):"
  }
  gn gen out
  ninja -C out src:foo_Test
  run bam test --runs-per-test 2 '//src:foo'

  print_result | grep 'running test' | diff -u <(expected) -
  [ "$status" -eq 0 ]
}

@test "'bam test --test-arg <arg>' appends args to tests" {
  function expected() {
    echo "echo foo_pretest &&  ut/foo_UT --foo-test-flags --more-foo-test-flags \"foo\" \"bar\""
    echo "touch ut/obj/src/foo_UT.pass"
  }
  gn gen out
  run bam test -n --test-arg 'foo' --test-arg 'bar' '//src:foo'

  diff -u <(expected) <(print_result | tail -n 2)
  [ "$status" -eq 0 ]
}

@test "'bam test --replace-test-args --test-arg <arg>' replaces args to tests" {
  function expected() {
    echo "echo foo_pretest &&  ut/foo_UT \"--arg1\" \"--arg2\""
    echo "touch ut/obj/src/foo_UT.pass"
  }
  gn gen out
  run bam test -n --replace-test-args --test-arg '--arg1' --test-arg '--arg2' '//src:foo'

  diff -u <(expected) <(print_result | tail -n 2)
  [ "$status" -eq 0 ]
}

@test "'bam test --check-up-to-date' passes for build up-to-date" {
  gn gen out
  bam test //src:foo
  sleep 1
  run bam test --check-up-to-date //src:foo

  diff -u <(/dev/null) <(print_result)
  [ "$status" -eq 0 ]
}

@test "'bam test --check-up-to-date' fails for build not up-to-date" {
  function expected() {
    echo "bam-test: error: tests are out-of-date"
  }
  gn gen out
  sleep 1
  run bam test --check-up-to-date //src:foo

  diff -u <(expected) <(print_result | tail -n 1)
  [ "$status" -eq 1 ]
}
