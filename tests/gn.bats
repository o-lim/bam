#!/usr/bin/env bats

setup() {
  rm -rf foobar/out
  cd foobar
  gn gen -q out
}

teardown() {
  rm -rf out
  rm -rf ../.tmp
  cd ..
}

function print_result() {
  for line in "${lines[@]}"; do
    echo "$line"
  done
}

@test "top level target builds dependencies" {
  function expected() {
    echo "//src:bar"
    echo "//src:baz"
    echo "//src:foo"
    echo "//src:fu"
    echo "//src:fubar"
  }
  run gn desc out 'src:foobar' --show=deps

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "leaf targets have no dependencies" {
  function expected() {
    echo -n ""
  }
  run gn desc out 'src:foo' --show=deps

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "integrate target builds only integrate platforms" {
  function expected() {
    echo "//src:foobar(//build/toolchain:arm)"
    echo "  //src:bar(//build/toolchain:arm)"
    echo "    //src:bar_gen_src(//build/toolchain:arm)"
    echo "  //src:baz(//build/toolchain:arm)"
    echo "  //src:foo(//build/toolchain:arm)"
    echo "  //src:fu(//build/toolchain:arm)"
    echo "  //src:fubar(//build/toolchain:arm)"
    echo "//src:foobar(//build/toolchain:mingw32)"
    echo "  //src:bar(//build/toolchain:mingw32)"
    echo "    //src:bar_gen_src(//build/toolchain:mingw32)"
    echo "  //src:baz(//build/toolchain:mingw32)"
    echo "  //src:foo(//build/toolchain:mingw32)"
    echo "  //src:fu(//build/toolchain:mingw32)"
    echo "  //src:fubar(//build/toolchain:mingw32)"
    echo "//src:foobar(//build/toolchain:mingw64)"
    echo "  //src:bar(//build/toolchain:mingw64)"
    echo "    //src:bar_gen_src(//build/toolchain:mingw64)"
    echo "  //src:baz(//build/toolchain:mingw64)"
    echo "  //src:foo(//build/toolchain:mingw64)"
    echo "  //src:fu(//build/toolchain:mingw64)"
    echo "  //src:fubar(//build/toolchain:mingw64)"
    echo "//src:foobar"
    echo "  //src:bar"
    echo "    //src:bar_gen_src"
    echo "  //src:baz"
    echo "  //src:foo"
    echo "  //src:fu"
    echo "  //src:fubar"
  }
  run gn desc out ':integrate' --show=deps --tree --all

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "test target builds and runs unit test" {
  function expected() {
    echo "//src:foo_UT.pass(//build/toolchain:ut)"
    echo "  //src:foo_UT(//build/toolchain:ut)"
    echo "    //src:foo(//build/toolchain:ut)"
  }
  run gn desc out 'src:foo_Test' --show=deps --tree --all

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "test targets depend on tests of dependencies" {
  function expected() {
    echo "//src:bar_Test(//build/toolchain:ut)"
    echo "//src:baz_Test(//build/toolchain:ut)"
    echo "//src:foo_Test(//build/toolchain:ut)"
    echo "//src:foobar_UT.pass(//build/toolchain:ut)"
    echo "//src:fu_Test(//build/toolchain:ut)"
    echo "//src:fubar_Test(//build/toolchain:ut)"
  }
  run gn desc out 'src:foobar_Test' --show=deps

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "test_deps only apply to test exes" {
  function expectedTestDeps() {
    echo "//src:fu_UT.pass(//build/toolchain:ut)"
  }
  function expectedUTDeps() {
    echo "//src:bar(//build/toolchain:ut)"
    echo "//src:fu(//build/toolchain:ut)"
  }

  gn desc out 'src:fu_Test' --show=deps | diff -u <(expectedTestDeps) -
  gn desc out 'src:fu_UT(//build/toolchain:ut)' --show=deps | diff -u <(expectedUTDeps) -
  gn desc out 'src:fu(//build/toolchain:ut)' --show=deps | diff -u <(/dev/null) -
}

@test "test targets can override test name/extension and preserves suffix" {
  function expected() {
    echo "ut/fu_test_UT.ut"
  }
  run gn ls out 'src:fu_UT(//build/toolchain:ut)' --as=output

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "test targets do not override test name/extension pass token" {
  function expected() {
    echo "//out/ut/obj/src/fu_UT.pass"
  }
  run gn desc out 'src:fu_UT.pass(//build/toolchain:ut)' --show=outputs --as=output

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "test target builds and runs all unit tests" {
  function expected() {
    echo "//src:foobar(//build/toolchain:ut)"
    echo "//src:foobar_Test(//build/toolchain:ut)"
  }
  run gn desc out ':test' --show=deps

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "lint target builds performs lint on all lint platforms" {
  function expected() {
    echo "//:lint-headers(//build/toolchain:lint-arm)"
    echo "  //build/config/arm:lnt(//build/toolchain:lint-arm)"
    echo "    //build/config/arm:_lnt_lint_dir(//build/toolchain:lint-arm)"
    echo "//:lint-headers(//build/toolchain:lint-mingw32)"
    echo "  //build/config/mingw32:lnt(//build/toolchain:lint-mingw32)"
    echo "    //build/config/mingw32:_lnt_lint_dir(//build/toolchain:lint-mingw32)"
    echo "//:lint-headers(//build/toolchain:lint-mingw64)"
    echo "  //build/config/mingw64:lnt(//build/toolchain:lint-mingw64)"
    echo "    //build/config/mingw64:_lnt_lint_dir(//build/toolchain:lint-mingw64)"
    echo "//:lint-headers(//build/toolchain:lint-x86)"
    echo "  //build/config/x86:lnt(//build/toolchain:lint-x86)"
    echo "    //build/config/x86:_lnt_lint_dir(//build/toolchain:lint-x86)"
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
    echo "//src:foobar(//build/toolchain:lint-mingw32)"
    echo "  //build/config/mingw32:lnt(//build/toolchain:lint-mingw32)"
    echo "    //build/config/mingw32:_lnt_lint_dir(//build/toolchain:lint-mingw32)"
    echo "  //src:bar(//build/toolchain:lint-mingw32)"
    echo "    //build/config/mingw32:lnt(//build/toolchain:lint-mingw32)"
    echo "      //build/config/mingw32:_lnt_lint_dir(//build/toolchain:lint-mingw32)"
    echo "    //src:bar_gen_src(//build/toolchain:lint-mingw32)"
    echo "  //src:baz(//build/toolchain:lint-mingw32)"
    echo "    //build/config/mingw32:lnt(//build/toolchain:lint-mingw32)"
    echo "      //build/config/mingw32:_lnt_lint_dir(//build/toolchain:lint-mingw32)"
    echo "  //src:foo(//build/toolchain:lint-mingw32)"
    echo "    //build/config/mingw32:lnt(//build/toolchain:lint-mingw32)"
    echo "      //build/config/mingw32:_lnt_lint_dir(//build/toolchain:lint-mingw32)"
    echo "  //src:fu(//build/toolchain:lint-mingw32)"
    echo "    //build/config/mingw32:lnt(//build/toolchain:lint-mingw32)"
    echo "      //build/config/mingw32:_lnt_lint_dir(//build/toolchain:lint-mingw32)"
    echo "  //src:fubar(//build/toolchain:lint-mingw32)"
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
    echo "//src:foobar(//build/toolchain:lint-x86)"
    echo "  //build/config/x86:lnt(//build/toolchain:lint-x86)"
    echo "    //build/config/x86:_lnt_lint_dir(//build/toolchain:lint-x86)"
    echo "  //src:bar(//build/toolchain:lint-x86)"
    echo "    //build/config/x86:lnt(//build/toolchain:lint-x86)"
    echo "      //build/config/x86:_lnt_lint_dir(//build/toolchain:lint-x86)"
    echo "    //src:bar_gen_src(//build/toolchain:lint-x86)"
    echo "  //src:baz(//build/toolchain:lint-x86)"
    echo "    //build/config/x86:lnt(//build/toolchain:lint-x86)"
    echo "      //build/config/x86:_lnt_lint_dir(//build/toolchain:lint-x86)"
    echo "  //src:foo(//build/toolchain:lint-x86)"
    echo "    //build/config/x86:lnt(//build/toolchain:lint-x86)"
    echo "      //build/config/x86:_lnt_lint_dir(//build/toolchain:lint-x86)"
    echo "  //src:fu(//build/toolchain:lint-x86)"
    echo "    //build/config/x86:lnt(//build/toolchain:lint-x86)"
    echo "      //build/config/x86:_lnt_lint_dir(//build/toolchain:lint-x86)"
    echo "  //src:fubar(//build/toolchain:lint-x86)"
  }
  run gn desc out ':lint' --show=deps --tree --all

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "style target runs style checking on all targets" {
  function expected() {
    echo "//:style-headers"
    echo "  //:style-headers(//build/toolchain:style)"
    echo "//src:foobar(//build/toolchain:style)"
    echo "  //src:bar(//build/toolchain:style)"
    echo "    //src:bar_gen_src(//build/toolchain:style)"
    echo "  //src:baz(//build/toolchain:style)"
    echo "  //src:foo(//build/toolchain:style)"
    echo "  //src:fu(//build/toolchain:style)"
    echo "  //src:fubar(//build/toolchain:style)"
  }
  run gn desc out ':style' --show=deps --tree --all

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "style checker runs on all header files" {
  function expected() {
    echo "out/style/obj/include/bar.h.style"
    echo "out/style/obj/include/foo.hpp.style"
  }
  ninja -C out style-headers
  diff -u <(expected) <(find out -name '*.style' | sort)
}

@test "style check generates style tokens" {
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
    echo "out/style/obj/src/foobar_main.cpp.style"
    echo "out/style/obj/src/fu.m.style"
    echo "out/style/obj/src/fu.mm.style"
    echo "out/style/obj/src/fu_UT.cpp.style"
    echo "out/style/obj/src/libbar.a.style"
    echo "out/style/obj/src/subdir/fubar.cpp.style"
  }
  ninja -C out style
  diff -u <(expected) <(find out -name '*.style' | sort)
}

@test "ninja does not detect any errors/warnings" {
  run ninja -C out -t targets
  ! echo "${line[0]}" | grep 'ninja: warning:'
  [ "$status" -eq 0 ]
}

@test "does not lint assembly" {
  run ninja -C out -t commands lint-arm/foobar.lint

  test ! `print_result | grep 'bar\.asm\.lint'`
  test ! `print_result | grep 'bar\.arm\.lint'`
  [ "$status" -eq 0 ]
}

@test "does not lint platforms removed from lint_platforms" {
  run ninja -C out -t commands lint

  ! print_result | grep 'lint-mingw32/obj/src/foobar\.cpp\.lint'
  print_result | grep 'lint-x86/obj/src/foobar\.cpp\.lint'
  print_result | grep 'lint-arm/obj/src/foobar\.cpp\.lint'
  print_result | grep 'lint-mingw64/obj/src/foobar\.cpp\.lint'
  [ "$status" -eq 0 ]
}

@test "does not style assembly" {
  run ninja -C out -t commands style/foobar.style

  test ! `print_result | grep 'bar\.asm\.style'`
  test ! `print_result | grep 'bar\.arm\.style'`
  [ "$status" -eq 0 ]
}

@test "does not lint hxx/cxx files" {
  run ninja -C out -t commands lint

  test ! `print_result | grep 'foo\.cxx\.lint'`
  test ! `print_result | grep 'foo\.hxx\.lint'`
  [ "$status" -eq 0 ]
}

@test "does not style hxx/cxx files" {
  run ninja -C out -t commands style

  test ! `print_result | grep 'foo\.cxx\.style'`
  test ! `print_result | grep 'foo\.hxx\.style'`
  [ "$status" -eq 0 ]
}

@test "can specify custom assembly source extensions" {
  ninja -C out -t commands arm/foobar | grep 'bar\.arm\.o'
  ninja -C out -t commands arm/foobar | grep 'bar\.asm\.o'
}

@test "can specify a linker script as source file" {
  ninja -C out -t commands mingw32/foobar.exe | grep 'foobar\.ld'
}

@test "can specify custom linker script as source file" {
  ninja -C out -t commands mingw64/foobar.exe | grep 'foobar\.cmd'
}

@test "can specify custom object extensions" {
  ninja -C out -t commands mingw32/foobar.exe | grep 'foo\.oo'
}

@test "generates one test exe per target by default" {
  function expected() {
    echo "//src:foo_UT.pass(//build/toolchain:ut)"
    echo "  //src:foo_UT(//build/toolchain:ut)"
    echo "    //src:foo(//build/toolchain:ut)"
  }
  run gn desc out 'src:foo_Test' --show=deps --tree --all

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "can override default 'is_one_test_exe_per_file' setting" {
  function expected() {
    echo "//src:bar_bar_UT1.pass(//build/toolchain:ut)"
    echo "  //src:bar_bar_UT1(//build/toolchain:ut)"
    echo "    //src:bar(//build/toolchain:ut)"
    echo "      //src:bar_gen_src(//build/toolchain:ut)"
    echo "    //src:bar_gen_src(//build/toolchain:ut)"
    echo "//src:bar_bar_UT2.pass(//build/toolchain:ut)"
    echo "  //src:bar_bar_UT2(//build/toolchain:ut)"
    echo "    //src:bar(//build/toolchain:ut)"
    echo "      //src:bar_gen_src(//build/toolchain:ut)"
    echo "    //src:bar_gen_src(//build/toolchain:ut)"
    echo "//src:bar_gen_src_Test(//build/toolchain:ut)"
  }
  run gn desc out 'src:bar_Test' --show=deps --tree --all

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "gn reports generic shell commands for actions" {
  function expected() {
    echo "date > gen/src/fubar.txt"
  }
  run gn desc out 'src:fubar' --show=command

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "can run generic shell commands for actions" {
  function expected() {
    echo "date > gen/src/fubar.txt"
  }
  run ninja -C out -t commands gen/src/fubar.txt

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "gn reports custom interpreter for actions" {
  function expected() {
    echo "lua"
  }
  run gn desc out 'src:bar_gen_src' --show=interpreter

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "can run custom interpreter for actions" {
  function expected() {
    echo "lua ../src/gen_src.lua gen/src/bar.cxx"
  }
  run ninja -C out -t commands gen/src/bar.cxx

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "can run custom interpreter for exec_script" {
  function expected() {
    echo "//src/README.txt"
  }
  run gn desc out 'src:foobar' --show=inputs

  diff -u <(expected) <(print_result)
  [ "$status" -eq 0 ]
}

@test "pre_test is overridable on a per target basis" {
  ninja -C out -t commands foo_Test | grep '^echo foo_pretest && '
}

@test "test_runner and test_runner_args are overridable on per target basis" {
  ninja -C out -t commands foo_Test | grep '&& bash -c '
}

@test "test_args overridable on a per target basis" {
  ninja -C out -t commands foo_Test | grep -- ' --foo-test-flags --more-foo-test-flags && '
}

@test "can use precompiled headers" {
  ninja -C out -t commands | grep -- '-include ut/obj/build/precompiled_ut\.h'
}

@test "output directory outside source root uses absolute paths for sources" {
  gn gen ../.tmp
  ninja -C ../.tmp -t commands obj/src/foobar.cpp.o | grep -- "-c $(pwd)/src/foobar\\.cpp"
}

@test "sources_assignment_filter should filter out matched sources from build" {
  ! ninja -C out -t commands | grep filtered_foobar
}

@test "post commands execute after asm/compile/link steps" {
  function expected() {
    echo "out/arm/foobar.link"
    echo "out/arm/libfu.solink"
    echo "out/arm/obj/out/arm/gen/src/bar.cxx.s"
    echo "out/arm/obj/src/bar.arm.ss"
    echo "out/arm/obj/src/bar.asm.ss"
    echo "out/arm/obj/src/bar.c.s"
    echo "out/arm/obj/src/baz.cpp.s"
    echo "out/arm/obj/src/foo.cxx.s"
    echo "out/arm/obj/src/foo1.cpp.s"
    echo "out/arm/obj/src/foo2.cpp.s"
    echo "out/arm/obj/src/foobar.cpp.s"
    echo "out/arm/obj/src/foobar_main.cpp.s"
    echo "out/arm/obj/src/fu.cc.s"
    echo "out/arm/obj/src/libbar.alink"
  }
  ninja -C out arm/foobar
  diff -u <(expected) <(find out/arm -name '*.s' -o -name '*.ss' -o -name '*.*link' | sort)
}
