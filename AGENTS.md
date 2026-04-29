# Agent Instructions

This repo is a single zsh script (`bin/mdview`) plus tests, install scripts,
and docs.

## Hard rules

- **zsh, not bash.** New shell code uses `#!/usr/bin/env zsh`, `.zsh` extension
  (except for `bin/mdview` itself, which is extensionless because it lives on
  PATH), and zsh idioms (`[[ ]]`, `(( ))`, `${var:t}`, `${var:A}`,
  `(( $+commands[name] ))`, `print -r --`).
- **Parse-check with `zsh -n`**, not shellcheck — shellcheck does not
  understand zsh.
- **Single-file user binary.** `bin/mdview` must remain self-contained. Don't
  split helpers into other files; the install path is "drop one file on PATH".
- **No new runtime dependencies.** pandoc, glow, mdcat, bat are all optional —
  the CDN fallback for HTML rendering is the floor.
- **Tests live in `tests/`.** Every behavioural change needs a test there.
  `make test` must pass before commit.
- **Tests stub `open`** so they never spawn a real browser. Preserve that.
- **Stdin escaping is a security property.** The textarea-embedding approach
  in `render_with_marked` is deliberate — read `tests/test-mdview.zsh` for
  the `</script>` test before changing it.
- **Don't rename or move `bin/mdview`** without updating `install.zsh`,
  `Makefile`, and the README install instructions.

## Workflow

1. `make lint` — fast feedback.
2. `make test` — full suite.
3. `make install` to dogfood locally.
4. Commit with a Conventional Commits-style message.
