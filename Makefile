SHELL    := /bin/bash
SRC      := resume.typ
LIB      := lib.typ $(wildcard lib/*.typ)
OUT_DIR  := output
OUT_PDF  := $(OUT_DIR)/resume.pdf
FONT_DIR := fonts

.PHONY: all build watch clean install fmt fmt-check check open help

all: build

build: $(OUT_DIR)
	typst compile --font-path $(FONT_DIR) $(SRC) $(OUT_PDF)

watch: $(OUT_DIR)
	typst watch --font-path $(FONT_DIR) $(SRC) $(OUT_PDF)

check:
	typst compile --font-path $(FONT_DIR) --diagnostic-format=human $(SRC) /dev/null

fmt:
	typstyle -i $(SRC) $(LIB)

fmt-check:
	typstyle --check $(SRC) $(LIB)

clean:
	rm -rf $(OUT_DIR)

open: $(OUT_PDF)
	open $(OUT_PDF)

install:
	brew install typst typstyle
	brew install --cask font-fontawesome

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

help:
	@echo "Build:"
	@echo "  build         Compile resume to $(OUT_PDF) (default)"
	@echo "  watch         Recompile on every save"
	@echo "  check         Compile-check without writing a PDF"
	@echo "  open          Open the built PDF"
	@echo "Format:"
	@echo "  fmt           Format .typ files in place with typstyle"
	@echo "  fmt-check     Verify formatting without rewriting"
	@echo "Other:"
	@echo "  clean         Remove $(OUT_DIR)/"
	@echo "  install       brew install typst typstyle + Font Awesome cask"
