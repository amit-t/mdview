---
title: Development
eyebrow: Contributors
description: Repo layout, dev loop, and release checklist for mdview.
---

Notes for hacking on mdview itself.

## Layout

```
mdview/
├── bin/mdview              # the only file end-users execute
├── completions/_mdview     # zsh completion (installed alongside the binary)
├── docs/
│   ├── USAGE.md            # extended user docs
│   └── DEVELOPMENT.md      # this file
├── tests/test-mdview.zsh   # end-to-end test suite
├── install.zsh             # symlink-based installer
├── Makefile                # test / lint / install / uninstall targets
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── AGENTS.md               # rules for AI / automation contributors
└── .github/workflows/ci.yml
```

## Loop

```bash
make lint            # zsh -n on all scripts
make test            # full e2e
make install         # dogfood — symlinks into ~/.local/bin
make uninstall       # clean up the symlinks
```

`make test` and `make lint` run on every push via GitHub Actions on both
Ubuntu and macOS — see `.github/workflows/ci.yml`.

## Adding a flag

1. Add the case to the `while (( $# > 0 ))` arg loop in `bin/mdview`.
2. Document it in the file's header comment block (the `usage()` extractor
   reads from there).
3. Mirror the entry in `README.md` and `docs/USAGE.md` flag tables.
4. Add a completion line in `completions/_mdview`.
5. Add a test case in `tests/test-mdview.zsh` covering both the happy path
   and at least one failure mode (missing arg, conflicting flag).
6. Bump `MDVIEW_VERSION` if you intend to ship a release.

## Testing approach

- The suite **never** spawns a real browser. It puts a fake `open` script
  ahead of macOS's `open` on `$PATH` and asserts against the captured
  invocation log.
- Tests run identically on macOS and Linux. The fake `open` makes the
  Linux runner happy too (no `xdg-open` needed).
- Pandoc is **optional**. Tests gate the `marked.js`-specific assertions
  behind `if ! (( $+commands[pandoc] ))` so they pass either way. To exercise
  the pandoc branch locally: `brew install pandoc && make test`.

## zsh idioms in use

- `${0:A}` — absolute, symlink-resolved path of the file currently being
  sourced/executed. Captured into `script_path` *before* any function
  defines, because inside a zsh function `$0` is the function name.
- `${var:t}` — basename, `${var:h}` — dirname.
- `(( $+commands[name] ))` — true iff `name` is on PATH.
- `print -r --` — like `printf '%s\n'`, doesn't interpret escapes; safer
  than `echo` for arbitrary strings.

## Release checklist

1. All tests green locally (`make lint test`) and in CI.
2. Bump `MDVIEW_VERSION` in `bin/mdview`.
3. Update `CHANGELOG.md` — move "Unreleased" entries under a new dated
   `## [x.y.z]` header. Add the comparison link at the bottom.
4. `git commit -am "chore(release): vX.Y.Z"`
5. `git tag vX.Y.Z && git push origin main --tags`
6. Cut the GitHub release from the tag — paste the changelog section as the
   release notes.
