include $(TOP_LEVEL_DIR)/header.mk

LNT_DIR := $(CURRENT_DIR)

MISC_FILES = msg.txt msg-json.zip
ZIP_FILES = ansi.zip posix.zip co-rkit-ARM.zip co-rkit-51.zip co-rkit-STM8.zip

COMPILER_OPTIONS_FILES = \
	co.lnt co-arch.lnt co-ARMCC-5.lnt co-uVision-4-ARMCC-5.lnt \
	co-aztec.lnt co-tc.lnt co-tcwin.lnt co-bc.lnt co-bc4.lnt co-bc4wi.lnt \
	co-bc5.lnt co-cb.lnt co-bc5.h co-bcos2.lnt co-bcwin.lnt co-bs166.lnt \
	co-byte.lnt co-byte.h co-cc86.lnt co-cc386.lnt co-c86.lnt co-c86p.lnt \
	co-cosm.lnt co-cosm.h co-dl.lnt co-desm.lnt co-diab.lnt co-ec.lnt \
	co-frank.lnt gcc-readme.txt co-gcc.lnt co-gcc.h co-gcc.mak co-gnu.lnt \
	co-gnu3.lnt co-hc.lnt co-hp.lnt co-hpacc.lnt co-ht.lnt co-iar.lnt \
	co-iar78.lnt co-iar80.lnt co-ibm32.lnt co-ibmc2.lnt co-vage.lnt \
	co-vage.h co-in.lnt co-in386.lnt co-in96.lnt co-icb.lnt co-kc51.lnt \
	co-kc251.lnt co-kc166.lnt co-kc166xc.lnt co-kcarm.lnt co-lc2.lnt \
	co-lc3.lnt co-lc33.lnt co-lc6.lnt co-mwwin32.lnt co-mwppc.lnt \
	co-mwe_base.lnt co-mwhc08.lnt co-mwhc11.lnt co-mwhc12.lnt \
	co-mwhc16.lnt co-msc.lnt co-mswin.lnt co-msc20.lnt co-msc40.lnt \
	co-msc50.lnt co-msc60.lnt co-msc70.lnt co-msc71.lnt co-msc80.lnt \
	co-msc80.h co-msc90.lnt co-msc90.h co-msc100.lnt co-msc100.h \
	co-msc110.lnt co-msc110.h macros-msc.c macros-msc.cpp co-mc86.lnt \
	co-mc386.lnt co-mc.h co-mwc.lnt co-pic18.lnt co-pic30.lnt co-pic32.lnt \
	co-cci.lnt co-xc8.lnt co-xc16.lnt co-xc32.lnt co-powrc.lnt co-qc88.lnt \
	co-sc7.lnt co-sc.lnt co-sun.lnt co-sun5.lnt co-sun6.lnt co-ti320.lnt \
	co-tiger.lnt co-tor.lnt co-tsc.lnt co-unix.lnt co-wc16.lnt co-wc32.lnt \
	co-wcos2.lnt co-wh.lnt co-ztc.lnt

LIB_OPTIONS_FILES = \
	lib-atl.lnt lib-boost-emergency.lnt lib-bcl.lnt lib-bcl5.lnt \
	lib-owl.lnt lib-owl5.lnt lib-bcl.h lib-tv.lnt lib-corb.lnt \
	lib-gtk.lnt lib-in.h lib-win.lnt lib-w32.lnt lib-wnt.lnt lib-mfc.lnt \
	lib-ole.lnt lib-nstd.lnt lib-oinv.lnt lib-rw.lnt lib-rw.h \
	lib-stingray-grid.lnt lib-stingray-toolkit.lnt lib-stl.lnt \
	lib-vxw.lnt lib-zapp.lnt lib-zinc.lnt

ENV_OPTIONS_FILES = \
	env-tide.lnt env-bwin.lnt env-bc5.lnt env-cb.lnt env-keil.lnt \
	env-vc2.lnt env-vc4.lnt env-vc5.lnt env-vc6.lnt env-vc7.lnt \
	env-vc8.lnt env-vc9.lnt env-vc10.lnt env-cw.lnt env-cw6.lnt \
	env-cw7.lnt env-mw.lnt env-ecl-console.lnt env-html.lnt env-html.js \
	env-mew.lnt env-om.lnt env-posix.lnt env-sled.lnt env-sl3.lnt \
	env-und.lnt env-si.lnt env-vim.lnt env-xml.lnt

AUTHOR_OPTIONS_FILES = \
	au-barr10.lnt au-ds.lnt au-sm12.lnt au-sm3.lnt au-sm123.lnt \
	au-misra.lnt au-misra1.lnt au-misra2.lnt au-misra3.lnt \
	au-misra-cpp.lnt au-misra-cpp-alt.lnt au-netrino.lnt au-64.lnt \
	au-llp64.lnt au-lp64.lnt au-ilp64.lnt

LNT_FILES = $(COMPILER_OPTIONS_FILES) $(ENV_OPTIONS_FILES) \
            $(LIB_OPTIONS_FILES) $(AUTHOR_OPTIONS_FILES) $(MISC_FILES)

LNT_TGT_FILES = $(patsubst %,$(LNT_DIR)/%,$(LNT_FILES))
LNT_TGT_DIRS = $(patsubst %.zip,$(LNT_DIR)/%,$(ZIP_FILES))
LNT_ZIP_FILES = $(patsubst %,$(LNT_DIR)/%,$(ZIP_FILES))

define make-lnt-target
$(LNT_DIR)/$1:
	@echo Downloading $$@ ...
	@curl -s -L -o $$@ http://www.gimpel.com/html/pub90/$1
endef

all: lnt
install: install-lnt

.INTERMEDIATE: $(LNT_ZIP_FILES)

.PHONY: lnt
lnt: $(LNT_TGT_FILES) $(LNT_TGT_DIRS)
	@true

.PHONY: install-lnt
install-lnt:
	@install -d $(PREFIX) $(PREFIX)/share/bam-core/lnt
	@cp -fr $(LNT_TGT_FILES) $(LNT_TGT_DIRS) $(PREFIX)/share/bam-core/lnt

$(LNT_DIR)/posix: $(LNT_DIR)/posix.zip
	@cd $(LNT_DIR) && unzip -qo $(<F)

$(LNT_DIR)/%: $(LNT_DIR)/%.zip
	@mkdir -p $@
	@cd $@ && unzip -qo ../$(<F)

ifneq (.,$(LNT_DIR))
clean: $(LNT_DIR)/clean
endif

.PHONY: $(LNT_DIR)/clean
$(LNT_DIR)/clean:
	@rm -f $(LNT_TGT_FILES) $(LNT_ZIP_FILES)
	@rm -rf $(LNT_TGT_DIRS)

$(foreach lnt,$(LNT_FILES) $(ZIP_FILES),$(eval $(call make-lnt-target,$(lnt))))

include $(TOP_LEVEL_DIR)/footer.mk
