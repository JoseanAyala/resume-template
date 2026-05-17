# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A single-page resume written in [Typst](https://typst.app), ported from sb2nov/resume (LaTeX). Despite the repo name, there is no LaTeX in the tree — `.typ` files only. The only file the author edits to update content is `resume.typ`; everything under `lib/` is the template engine.

## Common commands

All workflows go through the Makefile.

```sh
make            # build output/resume.pdf
make watch      # typst watch — live rebuild on save
make fmt        # format .typ files in place via typstyle
make open       # open the built PDF
make clean      # rm -rf output/
```

One-time setup: `make install` (`brew install typst typstyle` plus the Font Awesome cask).

## Architecture

The template is a thin DSL over Typst built around three layers:

- **`resume.typ`** — content only. Calls `#show: resume` then a sequence of `header(...)`, `entry(...)`, `bullets(...)`, `skills(...)` blocks under `=` headings. This is the one file content edits touch.
- **`lib.typ`** — public entry point. Re-exports everything from `lib/` and defines the `resume` show rule that sets page size, body font/size, and the heading style (smallcaps + bottom rule). `resume.typ` only imports this one file (`#import "lib.typ": *`).
- **`lib/`** — implementation, split by concern:
  - `tokens.typ` — design tokens: 4pt spacing scale (`s1`…`s5`), type scale (`body-size`, `name-size`, etc.), `page-margin`, `rule-stroke`, and the `heading-font` / `body-font` family names. Change visual primitives here, not in components.
  - `icons.typ` — Font Awesome glyphs as named refs (`icons.phone`, `icons.github`, …). Font family names (`"Font Awesome 7 Free Solid"`, `"Font Awesome 7 Brands"`) must match the installed FA major version; bumping it requires updating both the family names here and `FA_VERSION` in `.github/workflows/release.yml`.
  - `components.typ` — `header`, `entry` (two-column grid with strong/emph rows), `bullets`, `skills` (label-prefixed bullets), and `underlined-link`.

The dependency direction is strictly `resume.typ → lib.typ → lib/*.typ`, with `components.typ` and `icons.typ` pulling from `tokens.typ`. Cycles would be a smell.

### Fonts

Typst discovers fonts from the OS. Supply Font Awesome via `make install` (Homebrew cask, macOS) — CI installs the matching FA major version into `~/.local/share/fonts/`. If icons render as `?` boxes, FA isn't on the system font path — fix the install rather than changing the glyph.

## CI / release

`.github/workflows/release.yml` runs on every push to `main` that touches a `.typ` file:

1. Set up Typst, restore/install Font Awesome into `~/.local/share/fonts/`
2. `make build`
3. Tag `v$(date -u +%Y.%m.%d)-$(git rev-parse --short HEAD)` and stamp it into the filename
4. Publish a GitHub Release with `resume-<tag>.pdf` attached
