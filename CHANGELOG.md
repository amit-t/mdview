# Changelog

All notable changes to **mdview** documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] — 2026-04-29

### Added
- First public release as a standalone repo (extracted from `amit-t/my-zsh-profiles`).
- `bin/mdview` — pure-zsh markdown previewer.
  - Browser mode (default), terminal mode (`-t`), print mode (`-p`).
  - Stdin support via `mdview -`.
  - `--app`, `--title`, `--output`, `--no-open` flags.
  - `--version` / `-V`.
- Renderer chain:
  1. `pandoc` (when installed) for offline GitHub-style HTML.
  2. Client-side fallback: `marked.js` + `github-markdown-css` + `highlight.js` from CDN, with the markdown embedded inside an HTML-escaped `<textarea>` so adversarial content (e.g. literal `</script>`) can't break the document.
- `install.zsh` — symlink installer with `--prefix` and `--uninstall` flags.
- `Makefile` — `test`, `lint`, `install`, `uninstall`, `version`, `clean`.
- Zsh completion at `completions/_mdview` for both `mdview` and `mdv`.
- End-to-end test suite (`tests/test-mdview.zsh`) — stubs `open` so no real browser launches; verifies help, version, modes, escaping, error paths.
- GitHub Actions CI: lint + tests on every push/PR.
- Docs: `README.md`, `docs/USAGE.md`, `docs/DEVELOPMENT.md`, `CONTRIBUTING.md`, `AGENTS.md`.

[1.0.0]: https://github.com/amit-t/mdview/releases/tag/v1.0.0
