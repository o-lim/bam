# This Makefile enables the automatic generation of macro definition
# headers, --i options and size options for Lint based on command-line
# switches passed to TI.
#
# Usage:
#
# 	make -f co-ti.mak \
#		CC_BIN='name of the C compiler binary' \
#		CXX_BIN='name of the C++ compiler binary' \
# 		CFLAGS='[usual C compile switches here]' \
# 		CXXFLAGS='[usual C++ compile switches here]' \
# 		CPPFLAGS='[usual common preprocessor switches here]' \
# 		COMMON_FLAGS='[usual C & C++ compile switches here]' \
#
# ... where 'make' is the name of the GNU Make program on your system.
# That invocation should generate the following files:
#
#       lint_cmac.h
#       lint_cppmac.h
#       ti-include-path.lnt
#       size-options.lnt
#
# Note, if you do not supply the options that you actually compile with,
# you may see undesired results.  Examples:
#
# 1) If you usually compile with -m64 but do not pass this in the
# COMMON_FLAGS variable when you run `make -f co-ti.mak` then Lint may
# see the wrong size options (so it may think e.g. that sizeof(void*) is
# 4, which of course is inappropriate if you compile your code in 64-bit
# mode).
#
# 2) The set of compile switches (even non-preprocessor switches like -O3)
# can affect the configuration of TI's preprocessor, which means it can
# affect how the preprocessor views the contents of system headers (and
# hence the token sequence it generates).  So if we don't see the right
# set of compile switches here then the program you Lint might not be the
# program you compile (even though the same .c and .cpp files are
# involved).
#
# See also the file ti-readme.txt (supplied with the Lint distribution).

COMMON_TI_OPTS:= $(COMMON_FLAGS) $(CPPFLAGS)
# We want to enable 'long long' for the purpose of extracting the value of
# 'sizeof(long long)'; see the 'sizes' target below.

C_OPTS:=  $(CFLAGS) $(COMMON_TI_OPTS)
CXX_OPTS:=$(CXXFLAGS) $(COMMON_TI_OPTS)
# Note, we're not *yet* able to handle some of the header contents when
# -std=c++0x is given.

CC_BIN:=cc
CXX_BIN:=cxx

CC:=$(CC_BIN) $(C_OPTS)
CXX:=$(CXX_BIN) $(CXX_OPTS)

TEMP_FILE_PREFIX:=co-ti.mak.temp

E:=$(TEMP_FILE_PREFIX)-empty
SIZE_GEN:=$(TEMP_FILE_PREFIX)-generate-size-options

ECHO:=echo
TOUCH:=touch
AWK:=awk

DEVICE_NAME=$(shell \
	$(CC_BIN) -h | head -n 1 | \
	sed -e 's/TMS320//' -e 's| C/C++.*||' | \
	sed -e 's/ /_/g' \
)

.PHONY = clean clean_temps

config: clean preprocessor sizes clean_temps

preprocessor: macros include_path

empty_files:
	$(RM) $(E)*
	$(TOUCH) $(E).cpp $(E).c

macros: empty_files
	$(CC)  -ppm=lint_cmac.h $(E).c
	$(CXX) -ppm=lint_cppmac.h $(E).cpp

include_path:
	@# The #include search path is set by the C_DIR and device specific
	@# <device>_C_DIR environment variables.
	$(ECHO) "$(C_DIR);$($(DEVICE_NAME)_C_DIR)" | sed -e 's/;/\n/g' | \
		sed -e '/^ *$$/d' -re 's/^(.*)/--i"\1"/' > ti-include-path.lnt
	@# Note, we deliberately use '--i' instead of '-i' here; the effect
	@# is that the directories named with the double-dash form are
	@# searched after directories named with the single-dash form.
	@# (See also the entry for '--i' in section 5.7 of the Lint
	@# manual.)
	@#
	@# We typically use '--i' when we want to name a system include
	@# directory, which TI searches only after it searches all
	@# directories named in a '-I' option.  The upshot is that the
	@# correct search order (i.e., project includes before system
	@# includes) is preserved even when double-dash-i options are given
	@# before single-dash-i options.
	@#
	@# Also note, no harm is done if '-I' options are passed to TI
	@# here:  directories named with '-I' will appear before the
	@# sys-include-dirs in TI's output, so even though Lint might then
	@# see a project-include directory named with a '--i' option, that
	@# directory will still be searched before the sys-includes because
	@# of the ordering of '--i' options.  (Just make sure you don't use
	@# the double-dash form with project include dirs outside of this
	@# limited & generated sub-sequence of options because this is the
	@# only place where we are certain that project directories always
	@# come before system directories.)


sizes:
	$(RM) $(SIZE_GEN)*
	@# 'echo' seems to vary in behavior with respect to its handling
	@# of '\n'.  (Is it a newline, or a literal backslash followed by
	@# a literal 'n'?  It seems to depend on your platform.)  So we
	@# deliberately avoid the use of explicit newline characters here.
	@$(ECHO) '#include <limits>' > $(SIZE_GEN).cc
	@$(ECHO) '#include <stdint.h>' >> $(SIZE_GEN).cc
	@$(ECHO) '#include <float.h>' >> $(SIZE_GEN).cc
	@$(ECHO) '\
unsigned int tobits(unsigned long long const maxval) {\
  switch (maxval) { \
  case 0xff: return 8;\
  case 0x7f: return 8;\
  case 0xffff: return 16;\
  case 0x7fff: return 16;\
  case 0xffffffff: return 32;\
  case 0x7fffffff: return 32;\
  case 0xffffffffffffffff: return 64;\
  case 0x7fffffffffffffff: return 64;\
  }\
}\
unsigned int sexpdigits(unsigned int const maxexp) {\
  unsigned int count = 0;\
  while ((maxexp >> (++count)) != 0) { }\
  return count;\
}\
extern  "C" int printf(const char*, ...);\
int main() {\
printf( "-sb%u  ", CHAR_BIT );\
printf( "-ss%u  ", tobits(USHRT_MAX)/CHAR_BIT );\
printf( "-si%u  ", tobits(UINT_MAX)/CHAR_BIT );\
printf( "-sl%u  ", tobits(ULONG_MAX)/CHAR_BIT );\
printf( "-sll%u ", tobits(ULLONG_MAX)/CHAR_BIT );\
printf( "-sf%u  ", (FLT_MANT_DIG + sexpdigits(FLT_MAX_EXP))/CHAR_BIT );\
printf( "-sd%u  ", (DBL_MANT_DIG + sexpdigits(DBL_MAX_EXP))/CHAR_BIT );\
printf( "-sld%u ", (LDBL_MANT_DIG + sexpdigits(LDBL_MAX_EXP))/CHAR_BIT );\
printf( "-sp%u  ", tobits(SIZE_MAX)/CHAR_BIT );\
printf( "-sw%u  ", __TI_WCHAR_T_BITS__/CHAR_BIT );\
}' >> $(SIZE_GEN).cc
	$(CXX) -D__STDC_LIMIT_MACROS -ppo $(SIZE_GEN).cc
	tail -n 1 $(SIZE_GEN).pp > $(SIZE_GEN).cpp
	g++ -w $(SIZE_GEN).cpp -o $(SIZE_GEN)
	./$(SIZE_GEN) > size-options.lnt
	@# ... and make it newline-terminated:
	@$(ECHO) ""  >> size-options.lnt

clean_temps:
	$(RM) $(TEMP_FILE_PREFIX)*

clean:
	$(RM) \
	    lint_cppmac.h \
	    lint_cmac.h \
	    ti-include-path.lnt \
	    size-options.lnt

