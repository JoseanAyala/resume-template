# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single-page resume written in [Typst](https://typst.app), ported from sb2nov/resume (LaTeX). Despite the repo name, there is no LaTeX in the tree — `.typ` files only. The only file the author edits to update content is `resume.typ`; everything under `lib/` is the template engine.

## Common commands

All workflows go through the Makefile.

```sh
make            # build output/resume.pdf
make watch      # typst watch — live rebuild on save
make check      # compile-check without writing a PDF (CI-style validation)
make fmt        # format .typ files in place via typstyle
make fmt-check  # verify formatting without rewriting
make open       # open the built PDF
make clean      # rm -rf output/

# Diff against a published GitHub Release (defaults to latest)
make test               # test-content + test-visual
make test-content       # strict word-multiset equality — the gating check
make test-visual        # pixel diff; writes output/diff.pdf on mismatch (informational)
make ref                # fetch reference PDF from the latest release
make test REF_TAG=v2026.05.17-abc1234   # pin a specific release tag

# Fonts (Google Fonts via fontsource CDN → fonts/)
make font FAMILY="Manrope"        # fetch all weights/styles
make font-rm FAMILY="Manrope"     # remove a fetched family
```

One-time setup: `make install` (`brew install gh typst typstyle diff-pdf poppler` plus the Font Awesome cask).

There is no test framework and no unit tests — "tests" are PDF-diff checks against the last published release.

## Architecture

The template is a thin DSL over Typst built around three layers:

- **`resume.typ`** — content only. Calls `#show: resume` then a sequence of `header(...)`, `entry(...)`, `bullets(...)`, `skills(...)` blocks under `=` headings. This is the one file content edits touch.
- **`lib.typ`** — public entry point. Re-exports everything from `lib/` and defines the `resume` show rule that sets page size, body font/size, and the heading style (smallcaps + bottom rule). `resume.typ` only imports this one file (`#import "lib.typ": *`).
- **`lib/`** — implementation, split by concern:
  - `tokens.typ` — design tokens: 4pt spacing scale (`s1`…`s5`), type scale (`body-size`, `name-size`, etc.), `page-margin`, `rule-stroke`, and the `heading-font` / `body-font` family names. Change visual primitives here, not in components.
  - `icons.typ` — Font Awesome glyphs as named refs (`icons.phone`, `icons.github`, …). Font family names (`"Font Awesome 7 Free Solid"`, `"Font Awesome 7 Brands"`) must match what's installed locally and what CI fetches; bumping the FA major version requires updating both the family names here and `FA_VERSION` in `.github/workflows/release.yml`.
  - `components.typ` — `header`, `entry` (two-column grid with strong/emph rows), `bullets`, `skills` (label-prefixed bullets), and `underlined-link`.

The dependency direction is strictly `resume.typ → lib.typ → lib/*.typ`, with `components.typ` and `icons.typ` pulling from `tokens.typ`. Cycles would be a smell.

### Fonts

Typst is invoked with `--font-path fonts/`. The `fonts/` directory is gitignored and empty in a fresh clone; supply fonts via:
- `make install` (Homebrew cask for Font Awesome system-wide), or
- `make font FAMILY="..."` to drop TTFs into `fonts/`, or
- in CI, the release workflow downloads Font Awesome OTFs into `fonts/` (cached by `FA_VERSION`).

If a build renders icons as `?` boxes, the Font Awesome family in `lib/icons.typ` is not on the font path — fix the install rather than changing the glyph.

## CI / release

`.github/workflows/release.yml` runs on every push to `main`:

1. Set up Typst, restore/install Font Awesome into `fonts/`
2. `make build`
3. Tag `v$(date -u +%Y.%m.%d)-$(git rev-parse --short HEAD)`
4. Publish a GitHub Release with `output/resume.pdf` attached

`make test` diffs the current build against whatever release tag is fetched, so locally-passing `test-content` means the PDF still has the same words as the last release.
