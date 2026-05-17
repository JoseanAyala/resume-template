<h1 align="center">resume</h1>

<p align="center">
  A <a href="https://typst.app">Typst</a> port of <a href="https://github.com/sb2nov/resume">sb2nov/resume</a> — opinionated single-page layout.
  <br/>
  Fork the repo, rewrite <code>resume.typ</code>, push to <code>main</code>, get a tagged PDF release.
</p>

<p align="center">
  <a href="https://github.com/JoseanAyala/resume/actions/workflows/release.yml"><img alt="Release" src="https://github.com/JoseanAyala/resume/actions/workflows/release.yml/badge.svg" /></a>
  <a href="https://github.com/JoseanAyala/resume/releases/latest"><img alt="Latest release" src="https://img.shields.io/github/v/release/JoseanAyala/resume?label=resume" /></a>
  <a href="LICENSE"><img alt="MIT license" src="https://img.shields.io/badge/license-MIT-blue.svg" /></a>
  <img alt="Made with Typst" src="https://img.shields.io/badge/made%20with-Typst-239DAD.svg" />
</p>

<p align="center">
  <a href="https://github.com/JoseanAyala/resume/releases/latest"><strong>Download the latest resume</strong></a>
</p>

## Quick start

```sh
make install   # one-time: brew install gh typst typstyle diff-pdf poppler
make           # build output/resume.pdf
make watch     # live-rebuild on save
make test      # diff against the latest GitHub Release (override with REF_TAG=v...)
```

## Layout

```
resume.typ           # content — the only file you edit to make it yours
lib.typ              # public entry: `#import "lib.typ": *` re-exports everything below
lib/
  tokens.typ         # design tokens: spacing scale, type sizes, layout, fonts
  icons.typ          # Font Awesome glyphs as named refs (icons.phone, icons.github)
  components.typ     # header, entry, bullets, skills
fonts/               # font path passed to typst via --font-path (empty in repo; CI fetches FA)
```

## CI

Every push to `main` triggers [`.github/workflows/release.yml`](.github/workflows/release.yml):

1. Build the PDF with Typst
2. Tag `v<UTC-date>-<sha>`
3. Publish a GitHub Release with `resume.pdf` attached

The latest build is always at `releases/latest/download/resume.pdf`.

## Editing in Neovim

LSP via [tinymist](https://github.com/Myriad-Dreamin/tinymist), formatting via [typstyle](https://github.com/Enter-tainer/typstyle), browser preview via [typst-preview.nvim](https://github.com/chomosuke/typst-preview.nvim). Open a `.typ` file, then `<leader>tp` to launch the preview.

## Credits

The visual design comes from [sb2nov/resume](https://github.com/sb2nov/resume) (MIT) — this repo is a Typst rewrite of that LaTeX template. Icons are [Font Awesome Free](https://fontawesome.com/) (CC BY 4.0 / SIL OFL 1.1).

## License

MIT — see [LICENSE](LICENSE). Fork it, change the content, ship it.
