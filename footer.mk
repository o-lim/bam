CURRENT_DIR := $(DIRSTACK_$(SP))
SP := $(basename $(SP))
