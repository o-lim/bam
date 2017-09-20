#!/usr/bin/env bats

setup() {
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

@test "is_one_test_exe_per_file=true builds and runs one unit test exe per unit test source file" {
  function expected() {
    echo "//src:foo_foo1_UT.pass(//build/toolchain:ut)"
    echo "  //src:foo_foo1_UT(//build/toolchain:ut)"
    echo "    //src:foo(//build/toolchain:ut)"
    echo "//src:foo_foo2_UT.pass(//build/toolchain:ut)"
    echo "  //src:foo_foo2_UT(//build/toolchain:ut)"
    echo "    //src:foo(//build/toolchain:ut)"
  }
  gn gen out --args='is_one_test_exe_per_file=true'
  run gn desc out 'src:foo_Test' --show=deps --tree --all

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "is_one_test_exe_per_file=true can override test name/extension" {
  function expected() {
    echo "ut/fu_test/fu_UT.ut"
  }
  gn gen out --args='is_one_test_exe_per_file=true'
  run gn ls out 'src:fu_fu_UT(//build/toolchain:ut)' --as=output

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "is_one_test_exe_per_file=true does not override test name/extension pass token" {
  function expected() {
    echo "//out/ut/obj/src/fu_fu_UT.pass"
  }
  gn gen out --args='is_one_test_exe_per_file=true'
  run gn desc out 'src:fu_fu_UT.pass(//build/toolchain:ut)' --show=outputs --as=output

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "enable_style=false disables style checking rules for source files" {
  gn gen out --args='enable_style=false'
  ! ninja -C out -t targets depth 0 | grep -E '(c|cpp|h|hpp|m|mm)\.style'
}

@test "style_mode=list only styles sources" {
  function expected() {
    echo "out/style/foobar.style"
    echo "out/style/libbaz.so.style"
    echo "out/style/libfu.so.style"
    echo "out/style/obj/include/bar.h.style"
    echo "out/style/obj/include/foo.hpp.style"
    echo "out/style/obj/src/foobar.cpp.style"
    echo "out/style/obj/src/foobar_UT.cpp.style"
    echo "out/style/obj/src/fu.m.style"
    echo "out/style/obj/src/fu.mm.style"
    echo "out/style/obj/src/fu_UT.cpp.style"
    echo "out/style/obj/src/libbar.a.style"
  }
  gn gen out --args='style_mode="list"'
  ninja -C out style
  diff -u <(expected) <(find out -name '*.style' | sort)
}

@test "style_regex=*\\.c$ only styles c files" {
  function expected() {
    echo "out/style/foobar.style"
    echo "out/style/libbaz.so.style"
    echo "out/style/libfu.so.style"
    echo "out/style/obj/include/bar.h.style"
    echo "out/style/obj/include/foo.hpp.style"
    echo "out/style/obj/src/bar.c.style"
    echo "out/style/obj/src/fu.m.style"
    echo "out/style/obj/src/fu.mm.style"
    echo "out/style/obj/src/libbar.a.style"
  }
  gn gen out --args='style_regex=".*\\.c\$"'
  ninja -C out style
  diff -u <(expected) <(find out -name '*.style' | sort)
}

@test "style_depth=1 only styles to depth 1" {
  function expected() {
    echo "out/style/foobar.style"
    echo "out/style/libbaz.so.style"
    echo "out/style/libfu.so.style"
    echo "out/style/obj/include/bar.h.style"
    echo "out/style/obj/include/foo.hpp.style"
    echo "out/style/obj/src/bar.c.style"
    echo "out/style/obj/src/bar_UT1.cpp.style"
    echo "out/style/obj/src/bar_UT2.cpp.style"
    echo "out/style/obj/src/baz.cpp.style"
    echo "out/style/obj/src/baz.hpp.style"
    echo "out/style/obj/src/baz_UT.cpp.style"
    echo "out/style/obj/src/foo1.cpp.style"
    echo "out/style/obj/src/foo1_UT.cpp.style"
    echo "out/style/obj/src/foo2.cpp.style"
    echo "out/style/obj/src/foo2_UT.cpp.style"
    echo "out/style/obj/src/foobar.cpp.style"
    echo "out/style/obj/src/foobar_UT.cpp.style"
    echo "out/style/obj/src/fu.m.style"
    echo "out/style/obj/src/fu.mm.style"
    echo "out/style/obj/src/fu_UT.cpp.style"
    echo "out/style/obj/src/libbar.a.style"
  }
  gn gen out --args='style_depth=1'
  ninja -C out style
  diff -u <(expected) <(find out -name '*.style' | sort)
}

@test "enable_lint=false does not generate lint rules for source files" {
  gn gen out --args='enable_lint=false'
  ! ninja -C out -t targets depth 0 | grep -E '(c|cpp)\.lint'
}

@test "set platforms arg only builds specified platforms" {
  function expected() {
    echo "//src:foobar(//build/toolchain:mingw32)"
    echo "  //src:bar(//build/toolchain:mingw32)"
    echo "    //src:bar_gen_src(//build/toolchain:mingw32)"
    echo "  //src:baz(//build/toolchain:mingw32)"
    echo "  //src:foo(//build/toolchain:mingw32)"
    echo "  //src:fu(//build/toolchain:mingw32)"
    echo "  //src:fubar(//build/toolchain:mingw32)"
    echo "//src:foobar"
    echo "  //src:bar"
    echo "    //src:bar_gen_src"
    echo "  //src:baz"
    echo "  //src:foo"
    echo "  //src:fu"
    echo "  //src:fubar"
  }
  gn gen out --args='platforms=["x86", "mingw32"]'
  run gn desc out ':integrate' --show=deps --tree --all

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "set lint_platforms arg only lints specified platforms" {
  function expected() {
    echo "//:lint-headers(//build/toolchain:lint-arm)"
    echo "  //build/config/arm:lnt(//build/toolchain:lint-arm)"
    echo "    //build/config/arm:_lnt_lint_dir(//build/toolchain:lint-arm)"
    echo "//:lint-headers(//build/toolchain:lint-mingw64)"
    echo "  //build/config/mingw64:lnt(//build/toolchain:lint-mingw64)"
    echo "    //build/config/mingw64:_lnt_lint_dir(//build/toolchain:lint-mingw64)"
    echo "//src:foobar(//build/toolchain:lint-arm)"
    echo "  //build/config/arm:lnt(//build/toolchain:lint-arm)"
    echo "    //build/config/arm:_lnt_lint_dir(//build/toolchain:lint-arm)"
    echo "  //src:bar(//build/toolchain:lint-arm)"
    echo "    //build/config/arm:lnt(//build/toolchain:lint-arm)"
    echo "      //build/config/arm:_lnt_lint_dir(//build/toolchain:lint-arm)"
    echo "    //src:bar_gen_src(//build/toolchain:lint-arm)"
    echo "  //src:baz(//build/toolchain:lint-arm)"
    echo "    //build/config/arm:lnt(//build/toolchain:lint-arm)"
    echo "      //build/config/arm:_lnt_lint_dir(//build/toolchain:lint-arm)"
    echo "  //src:foo(//build/toolchain:lint-arm)"
    echo "    //build/config/arm:lnt(//build/toolchain:lint-arm)"
    echo "      //build/config/arm:_lnt_lint_dir(//build/toolchain:lint-arm)"
    echo "  //src:fu(//build/toolchain:lint-arm)"
    echo "    //build/config/arm:lnt(//build/toolchain:lint-arm)"
    echo "      //build/config/arm:_lnt_lint_dir(//build/toolchain:lint-arm)"
    echo "  //src:fubar(//build/toolchain:lint-arm)"
    echo "//src:foobar(//build/toolchain:lint-mingw64)"
    echo "  //build/config/mingw64:lnt(//build/toolchain:lint-mingw64)"
    echo "    //build/config/mingw64:_lnt_lint_dir(//build/toolchain:lint-mingw64)"
    echo "  //src:bar(//build/toolchain:lint-mingw64)"
    echo "    //build/config/mingw64:lnt(//build/toolchain:lint-mingw64)"
    echo "      //build/config/mingw64:_lnt_lint_dir(//build/toolchain:lint-mingw64)"
    echo "    //src:bar_gen_src(//build/toolchain:lint-mingw64)"
    echo "  //src:baz(//build/toolchain:lint-mingw64)"
    echo "    //build/config/mingw64:lnt(//build/toolchain:lint-mingw64)"
    echo "      //build/config/mingw64:_lnt_lint_dir(//build/toolchain:lint-mingw64)"
    echo "  //src:foo(//build/toolchain:lint-mingw64)"
    echo "    //build/config/mingw64:lnt(//build/toolchain:lint-mingw64)"
    echo "      //build/config/mingw64:_lnt_lint_dir(//build/toolchain:lint-mingw64)"
    echo "  //src:fu(//build/toolchain:lint-mingw64)"
    echo "    //build/config/mingw64:lnt(//build/toolchain:lint-mingw64)"
    echo "      //build/config/mingw64:_lnt_lint_dir(//build/toolchain:lint-mingw64)"
    echo "  //src:fubar(//build/toolchain:lint-mingw64)"
  }
  gn gen out --args='lint_platforms=["arm", "mingw64"]'
  run gn desc out ':lint' --show=deps --tree --all

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "enable_valgrind=true runs tests with valgrind" {
  gn gen out --args='enable_valgrind=true'
  ninja -C out -t commands foobar_Test | grep '^valgrind -q --leak-check=full --error-exitcode=5 --gen-suppressions=all'
}

@test "set valgrind args replaces default valgrind exe" {
  gn gen out --args='enable_valgrind=true valgrind="myvalgrind"'
  ninja -C out -t commands foobar_Test | grep '^myvalgrind'
}

@test "set valgrind_args args replaces default valgrind flags" {
  gn gen out --args='enable_valgrind=true valgrind_args=["--custom-valgrind-flags", "--more-flags"]'
  ninja -C out -t commands foobar_Test | grep '^valgrind --custom-valgrind-flags --more-flags'
}

@test "set pre_test args runs pre_test command" {
  gn gen out --args='pre_test="mypretest"'
  ninja -C out -t commands foobar_Test | grep '^mypretest && '
}

@test "set test_runner args runs with specified test runner" {
  gn gen out --args='test_runner="mytestrunner" test_runner_args=["--runner-flags"]'
  ninja -C out -t commands foobar_Test | grep '^mytestrunner --runner-flags '
}

@test "set test_args args runs with specified test flags" {
  gn gen out --args='test_args=["--my-test-flags", "--more-test-flags"]'
  ninja -C out -t commands foobar_Test | grep -- ' --my-test-flags --more-test-flags && '
}

@test "set is_debug=false args sets up release build configuration" {
  gn gen out --args='is_debug=false'
  ninja -C out -t commands foobar | grep -- '-DNDEBUG'
}

@test "set is_debug=true args sets up debug build configuration" {
  gn gen out --args='is_debug=true'
  ninja -C out -t commands foobar | grep -- '-D_DEBUG'
}

@test "set config=release args sets up release build configuration" {
  gn gen out --args='config="release"'
  ninja -C out -t commands foobar | grep -- '-DNDEBUG'
}

@test "set config=debug args sets up debug build configuration" {
  gn gen out --args='config="debug"'
  ninja -C out -t commands foobar | grep -- '-D_DEBUG'
}

@test "GN version variable is set to the correct version number" {
  run gn gen out --args='show_version=true'

  diff -u <(echo "bam version: $BAM_VERSION") <(echo "${lines[0]}")
  [ "$status" -eq 0 ]
}
