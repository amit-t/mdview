# mdview

[![Docs](https://img.shields.io/badge/docs-amit--t.github.io%2Fmdview-1f6feb?logo=github)](https://amit-t.github.io/mdview/)
[![CI](https://github.com/amit-t/mdview/actions/workflows/ci.yml/badge.svg)](https://github.com/amit-t/mdview/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> Preview any markdown (or MDX) file in your browser (or terminal) with one command.

`mdview` is a single-file [zsh](https://www.zsh.org/) script that turns a
markdown file (or stdin) into a styled HTML preview and opens it in your
default browser. `.mdx` files are detected automatically and rendered with
JSX, components, and `{ expressions }` intact. Optional terminal-mode and
"print HTML to stdout" flags make it equally happy in editors, scripts, and
pipelines.

- **One file, one PATH entry.** No npm, no Python, no virtualenv.
- **Pandoc when present, CDN fallback otherwise.** Works on a fresh Mac out
  of the box. Pandoc support kicks in automatically if installed.
- **MDX, seamlessly.** `mdview component.mdx` just works — Markdown + JSX
  rendered client-side via `@mdx-js/mdx` + React, with a graceful
  markdown-only fallback when components can't load.
- **Safe by construction.** Markdown is embedded into a `<textarea>` and
  HTML-escaped, so adversarial content (literal `</script>`, raw HTML, etc.)
  cannot break out of the page.
- **Tested.** End-to-end suite stubs the browser launcher; CI runs on
  macOS and Linux.

```bash
mdview README.md                     # render + open in default browser
mdview notes.md --app "Google Chrome"
mdview notes.md -t                   # terminal mode (glow → mdcat → bat → pager)
mdview notes.md -p > out.html        # print HTML to stdout
mdview notes.md -o /tmp/x.html -n    # write to a path, do not open
cat notes.md | mdview -              # read markdown from stdin
mdview component.mdx                 # MDX auto-detected → JSX rendered
cat post.mdx | mdview - --mdx        # force MDX for stdin / non-.mdx files
mdv  notes.md                        # short alias
```

## Contents

- [Install](#install)
  - [Homebrew tap (recommended on macOS)](#homebrew-tap-recommended-on-macos)
  - [Curl one-liner (any Unix)](#curl-one-liner-any-unix)
  - [Clone + `make install`](#clone--make-install)
  - [Manual / from source](#manual--from-source)
  - [Per-shell wiring (alias only)](#per-shell-wiring-alias-only)
- [Usage](#usage)
- [Flags](#flags)
- [How rendering works](#how-rendering-works)
- [Optional dependencies](#optional-dependencies)
- [Uninstall](#uninstall)
- [Development](#development)
- [License](#license)

---

## Install

`mdview` requires **zsh 5.x or newer** (default on macOS since Catalina;
Linux: `apt install zsh` / `dnf install zsh` / `pacman -S zsh`).
Everything else is optional.

> All install flows produce two commands on `PATH`: **`mdview`** (full name)
> and **`mdv`** (short alias).

### Homebrew tap (recommended on macOS)

```bash
brew tap amit-t/mdview https://github.com/amit-t/mdview
brew install mdview
```

That's it. `which mdview` should print
`/opt/homebrew/bin/mdview` (Apple Silicon) or `/usr/local/bin/mdview` (Intel).

> **Note:** the tap formula is published from `main`. Pin to a tag with
> `brew install mdview --HEAD` to track the latest commit, or use a tag with
> `brew install amit-t/mdview/mdview@1.0.0` once tagged releases are cut.

### Curl one-liner (any Unix)

For users who don't want to clone the repo. Drops the script and its short
alias into `~/.local/bin`. Works on macOS and Linux.

```bash
mkdir -p "$HOME/.local/bin"
curl -fsSL https://raw.githubusercontent.com/amit-t/mdview/main/bin/mdview \
  -o "$HOME/.local/bin/mdview"
chmod +x "$HOME/.local/bin/mdview"
ln -sfn "$HOME/.local/bin/mdview" "$HOME/.local/bin/mdv"
```

Then make sure `~/.local/bin` is on `PATH`. Add this to your shell rc
(`~/.zprofile`, `~/.zshrc`, or `~/.bashrc`) if it isn't already:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

To upgrade later, re-run the same `curl` command.

### Clone + `make install`

The "real" install — gives you the test suite, completions, and a clean
upgrade story (`git pull && make install`).

```bash
git clone https://github.com/amit-t/mdview.git
cd mdview
make install                  # installs into ~/.local (default)
# OR system-wide (needs sudo):
sudo make install PREFIX=/usr/local
```

What this does:

| Target                                        | Where                                     |
|-----------------------------------------------|-------------------------------------------|
| `bin/mdview`                                  | `$PREFIX/bin/mdview`                      |
| `bin/mdview` (alias)                          | `$PREFIX/bin/mdv`                         |
| `completions/_mdview`                         | `$PREFIX/share/zsh/site-functions/_mdview`|

Run `make help` for all available targets.

### Manual / from source

Don't like installers? Clone and add `bin/` to your `PATH`:

```bash
git clone https://github.com/amit-t/mdview.git ~/Projects/Libraries/mdview
echo 'export PATH="$HOME/Projects/Libraries/mdview/bin:$PATH"' >> ~/.zprofile
```

Open a new shell. `mdview --version` should print the current version.

### Per-shell wiring (alias only)

If you can't (or don't want to) add anything to `PATH`, you can alias
directly:

**zsh / bash:**
```bash
# in ~/.zprofile or ~/.bashrc
alias mdview="$HOME/Projects/Libraries/mdview/bin/mdview"
alias mdv="$HOME/Projects/Libraries/mdview/bin/mdview"
```

**fish:**
```fish
# in ~/.config/fish/config.fish
alias mdview="$HOME/Projects/Libraries/mdview/bin/mdview"
alias mdv="$HOME/Projects/Libraries/mdview/bin/mdview"
funcsave mdview
funcsave mdv
```

This keeps `mdview` invokable without modifying `PATH`, at the cost of
losing zsh tab-completion (which only attaches to commands on `PATH`).

---

## Usage

```text
mdview FILE [-b|-t|-p] [-o PATH] [-n] [--mdx|--md] [--app APP] [--title T]
mdview - [opts]              # read markdown from stdin
mdview -h | --help
mdview -V | --version
```

See [`docs/USAGE.md`](docs/USAGE.md) for the deeper tour — exit codes, editor
integration, security notes on the `<textarea>` embedding, and renderer
chain details.

## Flags

| Flag                | Effect                                                       |
|---------------------|--------------------------------------------------------------|
| `-b`, `--browser`   | Render to HTML and open (default).                           |
| `-t`, `--terminal`  | Render in terminal: `glow` → `mdcat` → `bat` → `$PAGER`.     |
| `-p`, `--print`     | Print rendered HTML to stdout (no file, no open).            |
| `-o`, `--output P`  | Save HTML to path `P` instead of an auto temp file.          |
| `-n`, `--no-open`   | Write the HTML file but skip launching the browser.          |
| `--mdx`             | Treat input as MDX (auto for `*.mdx`; forces it for stdin/`.md`). |
| `--md`              | Treat input as plain Markdown (overrides `.mdx` detection).  |
| `--app NAME`        | Open in a specific browser (`"Google Chrome"`, `"Safari"`).  |
| `--title TITLE`     | Override `<title>`. Default: file basename.                  |
| `-h`, `--help`      | Show help.                                                   |
| `-V`, `--version`   | Show version.                                                |

## How rendering works

Two paths, picked at runtime in this order:

1. **`pandoc`** — when installed, mdview shells out to
   `pandoc -f gfm -t html` and wraps the result in a styled document using
   `github-markdown-css`. Fully offline.
2. **`marked.js` fallback** — when pandoc isn't on PATH, mdview emits a
   self-contained HTML document that embeds the raw markdown inside a
   `<textarea id="md-source">` (HTML-escaped on the way in) and renders
   client-side using
   [`marked.js`](https://github.com/markedjs/marked) +
   [`highlight.js`](https://github.com/highlightjs/highlight.js) loaded from
   jsDelivr.

The `<textarea>` embedding is deliberate: the only sequence that closes a
textarea is `</textarea>`, so escaping `<` (and `&`) on the way in
neutralises any `</script>` or other tag-soup in the input. The test suite
has an explicit case proving this.

### MDX files

`.mdx` inputs (or any input with `--mdx`) skip the markdown chain entirely
and render client-side with [`@mdx-js/mdx`](https://mdxjs.com/) + React,
loaded as ESM from [esm.sh](https://esm.sh). This means JSX elements,
inline components (`export const Box = …`), and `{ expressions }` evaluate
in the browser exactly as MDX intends. The raw source is embedded in the
same HTML-escaped `<textarea>`, so the security property above is preserved.

If the full MDX render fails — most often because the file `import`s local
components that a browser can't resolve from a `file://` temp page — mdview
degrades to a **markdown-only preview** (ESM statement lines stripped,
remaining prose rendered with `marked.js`) and shows a notice, rather than a
blank page. Terminal mode (`-t`) similarly strips `import`/`export` lines and
renders the prose with `glow`/`mdcat`/`bat`.

> MDX needs network on first load to fetch the React + `@mdx-js` ESM bundles
> (then the browser caches them). Unlike the markdown path, there is no
> offline `pandoc` route for MDX — rendering JSX requires a JS runtime.

## Optional dependencies

Install whichever you actually use; mdview adapts.

| Tool                                                              | Used for                                       | Install (Homebrew)        |
|-------------------------------------------------------------------|------------------------------------------------|---------------------------|
| [`pandoc`](https://pandoc.org/)                                   | Offline HTML rendering (preferred over CDN)    | `brew install pandoc`     |
| [`glow`](https://github.com/charmbracelet/glow)                   | Terminal mode, themed                          | `brew install glow`       |
| [`mdcat`](https://github.com/swsnr/mdcat)                         | Terminal mode with image support               | `brew install mdcat`      |
| [`bat`](https://github.com/sharkdp/bat)                           | Terminal mode source view                      | `brew install bat`        |

## Uninstall

```bash
# matches the prefix you installed with
make uninstall                          # default ~/.local
sudo make uninstall PREFIX=/usr/local   # system-wide

# or via Homebrew:
brew uninstall mdview && brew untap amit-t/mdview
```

## Development

```bash
make lint            # parse-check all scripts (zsh -n)
make test            # full end-to-end suite, ~1s
make install         # dogfood
```

Test suite stubs `open` so it never spawns a real browser — safe to run on
CI. See [`CONTRIBUTING.md`](CONTRIBUTING.md) and
[`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md) for the full workflow,
release checklist, and zsh idioms in use.

CI runs on every push: lint + tests on Ubuntu and macOS. Smoke-installs into
a temp prefix on each run.

## License

[MIT](LICENSE) © 2026 Amit Tiwari.
