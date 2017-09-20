# This Makefile enables the automatic generation of macro definition
# headers, --i options and size options for Lint based on command-line
# switches passed to GHS.
#
# Usage:
#
# 	make -f co-ghs.mak \
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
#       ghs-include-path.lnt
#       size-options.lnt
#
# Note, if you do not supply the options that you actually compile with,
# you may see undesired results.  Examples:
#
# 1) If you usually compile with -m64 but do not pass this in the
# COMMON_FLAGS variable when you run `make -f co-ghs.mak` then Lint may
# see the wrong size options (so it may think e.g. that sizeof(void*) is
# 4, which of course is inappropriate if you compile your code in 64-bit
# mode).
#
# 2) The set of compile switches (even non-preprocessor switches like -O3)
# can affect the configuration of GHS's preprocessor, which means it can
# affect how the preprocessor views the contents of system headers (and
# hence the token sequence it generates).  So if we don't see the right
# set of compile switches here then the program you Lint might not be the
# program you compile (even though the same .c and .cpp files are
# involved).
#
# See also the file ghs-readme.txt (supplied with the Lint distribution).

COMMON_GHS_OPTS:= $(COMMON_FLAGS) $(CPPFLAGS)
# We want to enable 'long long' for the purpose of extracting the value of
# 'sizeof(long long)'; see the 'sizes' target below.

C_OPTS:=  $(CFLAGS) $(COMMON_GHS_OPTS)
CXX_OPTS:=$(CXXFLAGS) $(COMMON_GHS_OPTS)
# Note, we're not *yet* able to handle some of the header contents when
# -std=c++0x is given.

CC_BIN:=cc
CXX_BIN:=cxx

CC:=$(CC_BIN) $(C_OPTS)
CXX:=$(CXX_BIN) $(CXX_OPTS)

TEMP_FILE_PREFIX:=co-ghs.mak.temp

E:=$(TEMP_FILE_PREFIX)-empty
DUMMY:=$(TEMP_FILE_PREFIX)-dummy
SIZE_GEN:=$(TEMP_FILE_PREFIX)-generate-size-options

ECHO:=echo
TOUCH:=touch
AWK:=awk

.PHONY = clean clean_temps

config: clean preprocessor sizes clean_temps

preprocessor: macros include_path

empty_files:
	$(RM) $(E)*
	$(TOUCH) $(E).cpp $(E).c
	$(ECHO) "@define__GHS_REVISION_DATE __GHS_REVISION_DATE" > $(DUMMY).c
	$(ECHO) "@define__GHS_REVISION_VALUE __GHS_REVISION_VALUE" >> $(DUMMY).c
	$(ECHO) "@define__GHS_VERSION_NUMBER __GHS_VERSION_NUMBER" >> $(DUMMY).c

macros: empty_files
	$(CC)  -E -c_compiler.args=--list_macro $(E).c > lint_cmac.h
	$(CXX) -E -cxx_compiler.args=--list_macro $(E).cpp > lint_cppmac.h
	grep -q __GHS_VERSION_NUMBER lint_cmac.h || \
		$(CC) -E $(DUMMY).c | sed -n '2,$$s/@define/#define /p' \
		>> lint_cmac.h
	grep -q __GHS_VERSION_NUMBER lint_cppmac.h || \
		$(CC) -E $(DUMMY).c | sed -n '2,$$s/@define/#define /p' \
		>> lint_cppmac.h

include_path: empty_files
	@# Here we make options for the #include search path.
	@# Note, frameworks (a feature of Apple's GCC) are not supported
	@# yet so for now we filter them out.  Each remaining search
	@# directory 'foo' is transformed into '--i"foo"' after
	@# superfluous directory separators  are removed (as well as each
	@# CR character appearing immediately before a newline):
	$(CXX) -v -c $(E).cpp | sed -e 's|\\||' -e 's| |\n|g' | \
		sed -rn 's/(-I|--sys_include=)(.*)/--i"\2"/p' \
		> ghs-include-path.lnt
	@# Note, we deliberately use '--i' instead of '-i' here; the effect
	@# is that the directories named with the double-dash form are
	@# searched after directories named with the single-dash form.
	@# (See also the entry for '--i' in section 5.7 of the Lint
	@# manual.)
	@#
	@# We typically use '--i' when we want to name a system include
	@# directory, which GHS searches only after it searches all
	@# directories named in a '-I' option.  The upshot is that the
	@# correct search order (i.e., project includes before system
	@# includes) is preserved even when double-dash-i options are given
	@# before single-dash-i options.
	@#
	@# Also note, no harm is done if '-I' options are passed to GHS
	@# here:  directories named with '-I' will appear before the
	@# sys-include-dirs in GHS's output, so even though Lint might then
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
	@$(ECHO) '#include <float.h>' > $(SIZE_GEN).cc
	@$(ECHO) '\
unsigned int sexpdigits(unsigned int const maxexp) {\
  unsigned int count = 0;\
  while ((maxexp >> (++count)) != 0) { }\
  return count;\
}\
extern  "C" int printf(const char*, ...);\
int main() {\
printf( "-ss%u  ", __SHRT_BIT/8 );\
printf( "-si%u  ", __INT_BIT/8 );\
printf( "-sl%u  ", __LONG_BIT/8 );\
printf( "-sll%u ", __LLONG_BIT/8 );\
printf( "-sf%u  ", (FLT_MANT_DIG + sexpdigits(FLT_MAX_EXP))/8 );\
printf( "-sd%u  ", (DBL_MANT_DIG + sexpdigits(DBL_MAX_EXP))/8 );\
printf( "-sld%u ", __LDBL_BIT/8 );\
printf( "-sp%u  ", __PTR_BIT/8 );\
printf( "-sw%u  ", __WCHAR_BIT/8 );\
}' >> $(SIZE_GEN).cc
	$(CXX) -E $(SIZE_GEN).cc -o $(SIZE_GEN).ii
	tail -n 1 $(SIZE_GEN).ii > $(SIZE_GEN).cpp
	g++ $(SIZE_GEN).cpp -o $(SIZE_GEN)
	./$(SIZE_GEN) > size-options.lnt
	@# ... and make it newline-terminated:
	@$(ECHO) ""  >> size-options.lnt

clean_temps:
	$(RM) $(TEMP_FILE_PREFIX)*

clean:
	$(RM) \
	    lint_cppmac.h \
	    lint_cmac.h \
	    ghs-include-path.lnt \
	    size-options.lnt \
	    *.dla *.dnm *.map

