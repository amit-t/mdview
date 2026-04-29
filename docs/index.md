---
title: mdview
description: Preview any markdown file in your browser (or terminal) with one command.
---

# mdview

> Preview any markdown file in your browser (or terminal) with one command.

`mdview` is a single-file [zsh](https://www.zsh.org/) script that turns a
markdown file (or stdin) into a styled HTML preview and opens it in your
default browser. Optional terminal-mode and "print HTML to stdout" flags
make it equally happy in editors, scripts, and pipelines.

[View on GitHub](https://github.com/amit-t/mdview){: .btn .btn-primary }
[Usage guide](USAGE.html){: .btn }
[Development](DEVELOPMENT.html){: .btn }

---

## Why mdview

- **One file, one PATH entry.** No npm, no Python, no virtualenv.
- **Pandoc when present, CDN fallback otherwise.** Works on a fresh Mac
  out of the box. Pandoc support kicks in automatically if installed.
- **Safe by construction.** Markdown is embedded into a `<textarea>` and
  HTML-escaped, so adversarial content (literal `</script>`, raw HTML,
  etc.) cannot break out of the page.
- **Tested.** End-to-end suite stubs the browser launcher; CI runs on
  macOS and Linux.

## Quick taste

```bash
mdview README.md                     # render + open in default browser
mdview notes.md --app "Google Chrome"
mdview notes.md -t                   # terminal mode (glow → mdcat → bat → pager)
mdview notes.md -p > out.html        # print HTML to stdout
mdview notes.md -o /tmp/x.html -n    # write to a path, do not open
cat notes.md | mdview -              # read markdown from stdin
mdv  notes.md                        # short alias
```

## Install

`mdview` requires **zsh 5.x or newer** (default on macOS since Catalina;
on Linux: `apt install zsh` / `dnf install zsh` / `pacman -S zsh`).
Everything else is optional.

> All install flows produce two commands on `PATH`: **`mdview`** (full
> name) and **`mdv`** (short alias).

### Homebrew tap (recommended on macOS)

```bash
brew tap amit-t/mdview https://github.com/amit-t/mdview
brew install mdview
```

### Curl one-liner (any Unix)

Drops the script and its short alias into `~/.local/bin`:

```bash
mkdir -p "$HOME/.local/bin"
curl -fsSL https://raw.githubusercontent.com/amit-t/mdview/main/bin/mdview \
  -o "$HOME/.local/bin/mdview"
chmod +x "$HOME/.local/bin/mdview"
ln -sfn "$HOME/.local/bin/mdview" "$HOME/.local/bin/mdv"
```

Make sure `~/.local/bin` is on `PATH`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Clone + `make install`

```bash
git clone https://github.com/amit-t/mdview.git
cd mdview
make install                  # installs into ~/.local (default)
# OR system-wide (needs sudo):
sudo make install PREFIX=/usr/local
```

See the [README](https://github.com/amit-t/mdview#install) for every
install path (manual / per-shell alias / fish wiring).

## Flags at a glance

| Flag                | Effect                                                       |
|---------------------|--------------------------------------------------------------|
| `-b`, `--browser`   | Render to HTML and open (default).                           |
| `-t`, `--terminal`  | Render in terminal: `glow` → `mdcat` → `bat` → `$PAGER`.     |
| `-p`, `--print`     | Print rendered HTML to stdout (no file, no open).            |
| `-o`, `--output P`  | Save HTML to path `P` instead of an auto temp file.          |
| `-n`, `--no-open`   | Write the HTML file but skip launching the browser.          |
| `--app NAME`        | Open in a specific browser (`"Google Chrome"`, `"Safari"`).  |
| `--title TITLE`     | Override `<title>`. Default: file basename.                  |
| `-h`, `--help`      | Show help.                                                   |
| `-V`, `--version`   | Show version.                                                |

Full reference and examples in the [usage guide](USAGE.html).

## How rendering works

Two paths, picked at runtime in this order:

1. **`pandoc`** — when installed, mdview shells out to
   `pandoc -f gfm -t html` and wraps the result in a styled document
   using `github-markdown-css`. Fully offline.
2. **`marked.js` fallback** — when pandoc isn't on PATH, mdview emits a
   self-contained HTML document that embeds the raw markdown inside a
   `<textarea id="md-source">` (HTML-escaped on the way in) and renders
   client-side using
   [`marked.js`](https://github.com/markedjs/marked) +
   [`highlight.js`](https://github.com/highlightjs/highlight.js) loaded
   from jsDelivr.

The `<textarea>` embedding is deliberate: the only sequence that closes
a textarea is `</textarea>`, so escaping `<` (and `&`) on the way in
neutralises any `</script>` or other tag-soup in the input. The test
suite has an explicit case proving this.

## Documentation

- [Usage guide](USAGE.html) — every flag, edge case, and editor recipe.
- [Development notes](DEVELOPMENT.html) — repo layout, release checklist,
  zsh idioms.
- [Contributing](https://github.com/amit-t/mdview/blob/main/CONTRIBUTING.md)
- [Changelog](https://github.com/amit-t/mdview/blob/main/CHANGELOG.md)
- [Source on GitHub](https://github.com/amit-t/mdview)

## License

[MIT](https://github.com/amit-t/mdview/blob/main/LICENSE) © 2026 Amit
Tiwari.
