include $(TOP_LEVEL_DIR)/header.mk

DOCS_DIR := $(CURRENT_DIR)
BAM_DOCS := $(wildcard $(DOCS_DIR)/*.md)
BAM_MANPAGES := $(patsubst $(DOCS_DIR)/%.1.md,$(TOP_LEVEL_DIR)/man/man1/%.1,$(BAM_DOCS))
PANDOC_MAN_TEMPLATE_FILE := $(DOCS_DIR)/template.man

MAN_INSTALL_PATH := $(PREFIX)/share/man/man1
BAM_INSTALLED_MANPAGES := $(patsubst $(TOP_LEVEL_DIR)/man/man1/%,$(MAN_INSTALL_PATH)/%.gz,$(BAM_MANPAGES))

all: doc
install: install-doc

.PHONY: doc docs
doc docs: man
	@true

.PHONY: man
man: $(BAM_MANPAGES)
	@true

ifneq (.,$(DOCS_DIR))
clean: $(DOCS_DIR)/clean
endif

.PHONY: $(DOCS_DIR)/clean
$(DOCS_DIR)/clean:
	@rm -rf $(TOP_LEVEL_DIR)/man
	@rm -f $(PANDOC_MAN_TEMPLATE_FILE)

$(TOP_LEVEL_DIR)/man/man1:
	@mkdir -p $@

$(PANDOC_MAN_TEMPLATE_FILE): $(TOP_LEVEL_DIR)/libexec/bam-version $(DOCS_DIR)/rules.mk
	@pandoc -D man | sed "s/\\\$$footer\\\$$/Bam $$(PATH=$(TOP_LEVEL_DIR)/libexec:$$PATH $<)/g" > $@

$(TOP_LEVEL_DIR)/man/man1/%.1: $(DOCS_DIR)/%.1.md $(PANDOC_MAN_TEMPLATE_FILE) $(DOCS_DIR)/rules.mk | $(TOP_LEVEL_DIR)/man/man1
	@echo "Generating man page for $(*F)"
	@pandoc -f markdown -t man -s --template $(PANDOC_MAN_TEMPLATE_FILE) -o $@ $<

.PHONY: install-doc
install-doc: install-man
	@true

.PHONY: install-man
install-man: $(BAM_INSTALLED_MANPAGES)
	@true

$(MAN_INSTALL_PATH):
	@install -d $@

$(MAN_INSTALL_PATH)/%.1.gz: $(TOP_LEVEL_DIR)/man/man1/%.1 $(TOP_LEVEL_DIR)/prefix.mk | $(MAN_INSTALL_PATH)
	@sed -e 's|\\\@prefix\\\@|$(shell echo $(PREFIX) | sed 's/\([\\@\s-]\)/\\\1/g')|g' $< | gzip > $@

include $(TOP_LEVEL_DIR)/footer.mk
