---
title: Usage
description: Every flag, edge case, and workflow for mdview.
---

# mdview — usage

A deeper tour of the flags, edge cases, and workflows. The
[home page](index.html) has the quick start; this file has the rest.

## Modes

mdview has three output modes, mutually exclusive:

| Flag                | Effect                                                       |
|---------------------|--------------------------------------------------------------|
| `-b`, `--browser`   | Render to HTML and open in default browser (default).        |
| `-t`, `--terminal`  | Render in terminal: `glow` → `mdcat` → `bat` → `$PAGER`.     |
| `-p`, `--print`     | Print rendered HTML to stdout. No file written, no browser.  |

## Source: file or stdin

```bash
mdview README.md         # from a file
cat notes.md | mdview -  # from stdin (the bare dash)
```

When reading from stdin, the document `<title>` defaults to `stdin` — override
it with `--title`.

## Output target

```bash
mdview README.md                          # auto temp file, opens in browser
mdview README.md -o /tmp/preview.html     # write to a fixed path, then open
mdview README.md -o /tmp/x.html -n        # write, but skip launching browser
mdview README.md -p > /tmp/x.html         # print stage; you handle the file
```

`-o`/`--output` and `-p`/`--print` are independent: `-p` prints whatever you
*would* write, while `-o` controls *where* the on-disk copy goes.

## Choosing a browser

```bash
mdview notes.md --app "Google Chrome"
mdview notes.md --app "Safari"
mdview notes.md --app "Firefox"
mdview notes.md --app "Brave Browser"
mdview notes.md --app "Arc"
```

Anything macOS `open -a NAME` accepts works. On Linux, `--app` is silently
honoured by whatever `open` you have installed (most Linux setups don't
support `-a`; install [`xdg-open`](https://wiki.archlinux.org/title/Xdg-utils)
shim or skip the flag).

## Title override

```bash
mdview notes.md --title "April release notes"
```

The value is HTML-escaped before being inserted, so `--title 'A & B'` renders
as `A &amp; B` in the `<title>` element — safe to pass any string.

## Renderer chain

Two rendering paths, picked at runtime:

1. **`pandoc` (preferred)** — fully offline, GitHub-flavoured Markdown to
   HTML. mdview wraps the output in a styled document using
   `github-markdown-css` (loaded via CDN for the stylesheet only; the body
   is real, server-rendered HTML).
2. **`marked.js` fallback** — if `pandoc` isn't on PATH, mdview emits a
   document that embeds the raw markdown inside an HTML-escaped
   `<textarea id="md-source">` and renders it client-side using `marked.js` +
   `highlight.js` from a CDN. No server needed; works in any modern browser.

The fallback path requires network on first load (CDN). After that the
browser caches the JS/CSS like any other page.

### Why `<textarea>` embedding?

Putting the raw markdown directly inside a `<script>` tag would let any
literal `</script>` in the document break out and execute. The textarea is
an "escapable raw text" element — only `</textarea>` closes it — so
escaping `<` (along with `&`) on the way in eliminates the breakout vector
while leaving everything else round-trippable.

The test suite has an explicit case proving this:

```js
console.log("</script>"); // tricky terminator
```

…in the input markdown ends up as `&lt;/script>` in the HTML, and the
literal `</script>` sequence never appears in the rendered document.

## Terminal mode

Picks the first available terminal renderer:

1. [`glow`](https://github.com/charmbracelet/glow) — pretty, themed.
2. [`mdcat`](https://github.com/swsnr/mdcat) — image support in iTerm2 / Kitty.
3. [`bat`](https://github.com/sharkdp/bat) — syntax-highlighted source view.
4. `$PAGER` (`less -R` if unset) — plain fallback, always works.

Install whichever you like via `brew install glow` (or `mdcat`, or `bat`).
mdview adapts automatically.

## Exit codes

| Code | Meaning                                  |
|------|------------------------------------------|
| 0    | Success                                  |
| 1    | Internal error (e.g. missing input file) |
| 2    | Bad CLI usage (no args, unknown flag)    |

## Editor / git integration ideas

- **Open the current file**: `mdview "$(git rev-parse --show-toplevel)/README.md"`
- **Preview a PR description**: `gh pr view --json body -q .body | mdview -`
- **Preview release notes from the changelog**: `awk '/^## /{n++}n==1' CHANGELOG.md | mdview -`
- **Vim binding**: `nnoremap <leader>md :silent !mdview %<CR>`
- **VS Code task**: shell task with `mdview ${file}` — bind to a keystroke.
