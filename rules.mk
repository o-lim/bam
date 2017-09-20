include $(TOP_LEVEL_DIR)/header.mk

PATCH_INSTALL_FILES = bin/bam libexec/bam-core/bam-sh-setup

.PHONY: all
all:
	@true

.PHONY: clean
clean:
	@true

.PHONY: install
install: install-bin
	@true

.PHONY: install-bin
install-bin:
	@install -d $(PREFIX) $(PREFIX)/bin $(PREFIX)/libexec/bam-core $(PREFIX)/share/bam-core
	@cp -fr bin/* $(PREFIX)/bin
	@cp -fr libexec/* $(PREFIX)/libexec/bam-core
	@cp -fr config toolchain util $(PREFIX)/share/bam-core
	@cp -fr examples templates $(PREFIX)/share/bam-core
	@sed -i -e 's|\@prefix\@|$(shell echo $(PREFIX) | sed -r 's/([\\@\s])/\\\1/g')|g' $(patsubst %,$(PREFIX)/%,$(PATCH_INSTALL_FILES))

include $(TOP_LEVEL_DIR)/footer.mk
