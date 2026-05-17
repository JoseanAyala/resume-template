SHELL    := /bin/bash
SRC      := resume.typ
LIB      := lib.typ $(wildcard lib/*.typ)
OUT_DIR  := output
OUT_PDF  := $(OUT_DIR)/resume.pdf
REF_PDF  := $(OUT_DIR)/reference.pdf
DIFF_PDF := $(OUT_DIR)/diff.pdf
FONT_DIR := fonts

# Tag to diff against; empty = latest release.
# Usage: make test REF_TAG=v2026.05.17-abc1234
REF_TAG  ?=

.PHONY: all build watch clean install fmt fmt-check check open help \
        test test-content test-visual ref \
        font font-rm

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
	brew install gh typst typstyle diff-pdf poppler
	brew install --cask font-fontawesome

# Fetch the resume PDF from a GitHub Release as the diff target.
# Defaults to the latest release; pass REF_TAG=<tag> to pin a specific one.
ref: $(OUT_DIR)
	@gh release download $(REF_TAG) --pattern 'resume-*.pdf' --output $(REF_PDF) --clobber
	@echo "✓ fetched reference from release $${REF_TAG:-latest}"

# Word-multiset comparison: catches missing/extra words, ignores line-wrap
# and any non-alphanumeric characters.
test-content: $(OUT_PDF) ref
	@diff \
		<(pdftotext -layout $(REF_PDF) - | LC_ALL=C tr -cs '[:alnum:]' '\n' | sort) \
		<(pdftotext -layout $(OUT_PDF) - | LC_ALL=C tr -cs '[:alnum:]' '\n' | sort) \
		&& echo "✓ content matches reference (word-multiset)" \
		|| (echo "✗ content differs from reference (see word diff above)" && exit 1)

# Visual pixel-diff — informational, writes a highlighted diff PDF on mismatch.
test-visual: $(OUT_PDF) ref
	@diff-pdf --output-diff=$(DIFF_PDF) $(REF_PDF) $(OUT_PDF) \
		&& echo "✓ visually identical to reference" \
		|| echo "ℹ visual differences written to $(DIFF_PDF)"

test: test-content test-visual

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

$(FONT_DIR):
	mkdir -p $(FONT_DIR)

# Fetch static TTFs for a Google Font into $(FONT_DIR) via the fontsource CDN.
# Usage: make font FAMILY="Manrope"     (also handles multi-word like "IBM Plex Sans")
font: $(FONT_DIR)
	@if [ -z "$(FAMILY)" ]; then \
		echo "Usage: make font FAMILY=\"<Family Name>\""; exit 1; \
	fi
	@slug="$$(echo '$(FAMILY)' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"; \
	echo "Fetching $(FAMILY) ($$slug) into $(FONT_DIR)/..."; \
	got=0; \
	for w in 100 200 300 400 500 600 700 800 900; do \
		for s in normal italic; do \
			f="$(FONT_DIR)/$$slug-$$w-$$s.ttf"; \
			if curl -sSfL -o "$$f" "https://cdn.jsdelivr.net/fontsource/fonts/$$slug@latest/latin-$$w-$$s.ttf" 2>/dev/null; then \
				echo "  ✓ $$w $$s"; got=$$((got+1)); \
			else \
				rm -f "$$f"; \
			fi; \
		done; \
	done; \
	if [ $$got -eq 0 ]; then \
		echo "✗ no files fetched — is '$(FAMILY)' on fontsource? https://api.fontsource.org/v1/fonts/$$slug"; exit 1; \
	fi

# Remove a previously fetched family.
# Usage: make font-rm FAMILY="Manrope"
font-rm:
	@if [ -z "$(FAMILY)" ]; then \
		echo "Usage: make font-rm FAMILY=\"<Family Name>\""; exit 1; \
	fi
	@slug="$$(echo '$(FAMILY)' | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"; \
	rm -f $(FONT_DIR)/$$slug-*.ttf && echo "✓ removed $(FAMILY) from $(FONT_DIR)/"

help:
	@echo "Build:"
	@echo "  build         Compile resume to $(OUT_PDF) (default)"
	@echo "  watch         Recompile on every save"
	@echo "  check         Compile-check without writing a PDF"
	@echo "  open          Open the built PDF"
	@echo "Format:"
	@echo "  fmt           Format .typ files in place with typstyle"
	@echo "  fmt-check     Verify formatting without rewriting"
	@echo "Test (vs a GitHub Release — defaults to latest, override with REF_TAG=...):"
	@echo "  test          Run test-content + test-visual"
	@echo "  test-content  Strict text equality (gates green/red)"
	@echo "  test-visual   Pixel diff; writes $(DIFF_PDF) on mismatch"
	@echo "  ref           Fetch reference PDF from release (auto-run by test*)"
	@echo "Fonts (Google Fonts via fontsource CDN → $(FONT_DIR)/):"
	@echo "  font FAMILY=X    Fetch static TTFs for family X"
	@echo "  font-rm FAMILY=X Remove a fetched family"
	@echo "Other:"
	@echo "  clean         Remove $(OUT_DIR)/"
	@echo "  install       brew install gh typst typstyle diff-pdf poppler"
