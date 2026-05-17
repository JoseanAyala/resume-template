SRC      := resume.typ
LIB      := lib.typ $(wildcard lib/*.typ)
OUT_DIR  := output
OUT_PDF  := $(OUT_DIR)/resume.pdf

.PHONY: all build watch clean install fmt open help

all: build

build:
	@mkdir -p $(OUT_DIR)
	typst compile $(SRC) $(OUT_PDF)

watch:
	@mkdir -p $(OUT_DIR)
	typst watch $(SRC) $(OUT_PDF)

fmt:
	typstyle -i $(SRC) $(LIB)

clean:
	rm -rf $(OUT_DIR)

open: $(OUT_PDF)
	open $(OUT_PDF)

install:
	brew install typst typstyle
	brew install --cask font-fontawesome

help:
	@echo "  build    Compile resume to $(OUT_PDF) (default)"
	@echo "  watch    Recompile on every save"
	@echo "  fmt      Format .typ files with typstyle"
	@echo "  open     Open the built PDF"
	@echo "  clean    Remove $(OUT_DIR)/"
	@echo "  install  brew install typst typstyle + Font Awesome cask"
