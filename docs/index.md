---
layout: home
title: mdview
description: Preview any markdown file in your browser (or terminal) with one command.
hero_eyebrow: zsh · one file · zero deps
hero_title: Preview Markdown. One Command. No Setup.
hero_desc: >
  mdview is a single-file zsh script that turns a markdown file (or stdin) into a
  styled HTML preview and opens it in your default browser. Optional terminal-mode
  and "print HTML to stdout" flags make it equally happy in editors, scripts, and pipelines.
---

## Why mdview

<div class="feature-grid" markdown="0">
  <div class="feature-card">
    <span class="feature-card-tag tag-zero">One File</span>
    <h3 class="feature-card-title">Single zsh script</h3>
    <p class="feature-card-detail">No npm, no Python, no virtualenv. Drop <code>bin/mdview</code> on PATH and you are done.</p>
  </div>
  <div class="feature-card">
    <span class="feature-card-tag tag-render">Render</span>
    <h3 class="feature-card-title">Pandoc when present, CDN fallback otherwise</h3>
    <p class="feature-card-detail">Works on a fresh Mac out of the box. <code>pandoc</code> support kicks in automatically if installed.</p>
  </div>
  <div class="feature-card">
    <span class="feature-card-tag tag-browser">Browser</span>
    <h3 class="feature-card-title">Default browser, your choice</h3>
    <p class="feature-card-detail"><code>--app "Google Chrome"</code> picks any installed browser. macOS and Linux both supported.</p>
  </div>
  <div class="feature-card">
    <span class="feature-card-tag tag-terminal">Terminal</span>
    <h3 class="feature-card-title">Terminal mode too</h3>
    <p class="feature-card-detail"><code>-t</code> renders via <code>glow</code> → <code>mdcat</code> → <code>bat</code> → <code>$PAGER</code> — first one available wins.</p>
  </div>
  <div class="feature-card">
    <span class="feature-card-tag tag-pipe">Pipe</span>
    <h3 class="feature-card-title">Stdin and stdout friendly</h3>
    <p class="feature-card-detail"><code>cat notes.md | mdview -</code> reads stdin. <code>-p</code> prints rendered HTML so you can pipe it onward.</p>
  </div>
  <div class="feature-card">
    <span class="feature-card-tag tag-safe">Safe</span>
    <h3 class="feature-card-title">Safe by construction</h3>
    <p class="feature-card-detail">Markdown embeds in a <code>&lt;textarea&gt;</code> and is HTML-escaped — adversarial content cannot break out of the page.</p>
  </div>
</div>

## Install

<div class="install-commands">

### Homebrew tap (recommended on macOS)

```bash
brew tap amit-t/mdview https://github.com/amit-t/mdview
brew install mdview
```

### Curl one-liner (any Unix)

```bash
mkdir -p "$HOME/.local/bin"
curl -fsSL https://raw.githubusercontent.com/amit-t/mdview/main/bin/mdview \
  -o "$HOME/.local/bin/mdview"
chmod +x "$HOME/.local/bin/mdview"
ln -sfn "$HOME/.local/bin/mdview" "$HOME/.local/bin/mdv"
```

### Clone + `make install`

```bash
git clone https://github.com/amit-t/mdview.git
cd mdview
make install
```

</div>

> All install flows produce two commands on PATH: **`mdview`** (full name) and **`mdv`** (short alias).

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

## Flags at a glance

<table class="flag-table">
<thead>
<tr><th>Flag</th><th>Effect</th></tr>
</thead>
<tbody>
<tr><td><code>-b</code>, <code>--browser</code></td><td>Render to HTML and open (default).</td></tr>
<tr><td><code>-t</code>, <code>--terminal</code></td><td>Render in terminal: <code>glow</code> → <code>mdcat</code> → <code>bat</code> → <code>$PAGER</code>.</td></tr>
<tr><td><code>-p</code>, <code>--print</code></td><td>Print rendered HTML to stdout (no file, no open).</td></tr>
<tr><td><code>-o</code>, <code>--output P</code></td><td>Save HTML to path <code>P</code> instead of an auto temp file.</td></tr>
<tr><td><code>-n</code>, <code>--no-open</code></td><td>Write the HTML file but skip launching the browser.</td></tr>
<tr><td><code>--app NAME</code></td><td>Open in a specific browser (<code>"Google Chrome"</code>, <code>"Safari"</code>).</td></tr>
<tr><td><code>--title TITLE</code></td><td>Override <code>&lt;title&gt;</code>. Default: file basename.</td></tr>
<tr><td><code>-h</code>, <code>--help</code></td><td>Show help.</td></tr>
<tr><td><code>-V</code>, <code>--version</code></td><td>Show version.</td></tr>
</tbody>
</table>

Full reference and examples live in the [usage guide]({{ '/USAGE.html' | relative_url }}).

## How rendering works

Two paths, picked at runtime in this order:

1. **`pandoc`** — when installed, mdview shells out to `pandoc -f gfm -t html` and wraps the result in a styled document using `github-markdown-css`. Fully offline.
2. **`marked.js` fallback** — when pandoc isn't on PATH, mdview emits a self-contained HTML document that embeds the raw markdown inside a `<textarea id="md-source">` (HTML-escaped on the way in) and renders client-side using [`marked.js`](https://github.com/markedjs/marked) + [`highlight.js`](https://github.com/highlightjs/highlight.js) loaded from jsDelivr.

The `<textarea>` embedding is deliberate: the only sequence that closes a textarea is `</textarea>`, so escaping `<` (and `&`) on the way in neutralises any `</script>` or other tag-soup in the input. The test suite has an explicit case proving this.

## Documentation

- [**Usage guide**]({{ '/USAGE.html' | relative_url }}) — every flag, edge case, and editor recipe.
- [**Development notes**]({{ '/DEVELOPMENT.html' | relative_url }}) — repo layout, release checklist, zsh idioms.
- [**Contributing**]({{ '/CONTRIBUTING.html' | relative_url }}) — ground rules and test-with-every-PR policy.
- [**Changelog**]({{ '/CHANGELOG.html' | relative_url }}) — release history.
- [**Source on GitHub**](https://github.com/amit-t/mdview).
