include $(TOP_LEVEL_DIR)/header.mk

DOCS_DIR := $(CURRENT_DIR)
BAM_DOCS := $(wildcard $(DOCS_DIR)/*.md)
BAM_MANPAGES := $(patsubst $(DOCS_DIR)/%.1.md,$(TOP_LEVEL_DIR)/man/man1/%.1.gz,$(BAM_DOCS))
PANDOC_MAN_TEMPLATE_FILE := $(DOCS_DIR)/template.man

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

$(TOP_LEVEL_DIR)/man/man1:
	@mkdir -p $@

$(PANDOC_MAN_TEMPLATE_FILE): $(TOP_LEVEL_DIR)/libexec/bam-version $(DOCS_DIR)/rules.mk
	@pandoc -D man | sed "s/\\\$$footer\\\$$/Bam $$($<)/g" > $@

$(TOP_LEVEL_DIR)/man/man1/%.1.gz: $(DOCS_DIR)/%.1.md $(PANDOC_MAN_TEMPLATE_FILE) $(DOCS_DIR)/rules.mk $(TOP_LEVEL_DIR)/prefix.mk | $(TOP_LEVEL_DIR)/man/man1
	@echo "Generating man page for $(*F)"
	@sed -e 's|\@prefix\@|$(shell echo $(PREFIX) | sed -r 's/([\\@\s])/\\\1/g')|g' $< | pandoc -f markdown -t man -s --template $(PANDOC_MAN_TEMPLATE_FILE) | gzip > $@

.PHONY: install-doc
install-doc: install-man
	@true

.PHONY: install-man
install-man: man
	@install -d $(PREFIX)/share/man
	@cp -fr $(TOP_LEVEL_DIR)/man/* $(PREFIX)/share/man

include $(TOP_LEVEL_DIR)/footer.mk
