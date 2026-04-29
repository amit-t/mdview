# Contributing to mdview

Thanks for your interest. mdview is small on purpose — one zsh script, no
runtime deps. Contributions that keep that property are welcome.

## Quick start

```bash
git clone https://github.com/amit-t/mdview.git
cd mdview
make lint test            # parse + run e2e suite
make install              # symlink mdview + mdv into ~/.local/bin
```

## Ground rules

- **Pure zsh.** `#!/usr/bin/env zsh`, parse-checked with `zsh -n`. No bash
  isms. No new runtime dependencies in `bin/mdview`.
- **Single-file binary.** `bin/mdview` is the whole tool. Helpers that the
  user doesn't run directly belong in other files (install scripts, tests).
- **Add a test.** Every behaviour change needs an entry in
  `tests/test-mdview.zsh`. The suite stubs `open` so no real browser launches —
  keep it that way.
- **Run the suite.** `make lint && make test` is the bar before opening a PR.
- **Conventional Commits.** `feat:`, `fix:`, `docs:`, `test:`, `chore:`,
  `refactor:`. PR titles match the same style.

## Reporting bugs

Open an issue with:

1. macOS / Linux + `zsh --version`.
2. The exact command you ran.
3. Output of `mdview --version`.
4. A minimal markdown sample that reproduces the problem (paste it inline).

## Security

If you find a content-injection issue (markdown that escapes the rendered
document, breaks out of the `<textarea>` embedding, or executes against the
user's browser in an unexpected way), please **don't** open a public issue.
Email the maintainer (see `LICENSE` / git log for the address) with the repro.

## Style

- 4-space indent (see `.editorconfig`).
- One short comment per *why-not-obvious* block. No commentary on the
  obvious. Don't reference PRs, tickets, or "added for X" — that belongs in
  the PR description.
- Keep `--help` output in sync with `README.md`.

## Releasing (maintainer)

1. Bump `MDVIEW_VERSION` in `bin/mdview`.
2. Update `CHANGELOG.md`.
3. `git tag vX.Y.Z && git push --tags`.
4. Create the GitHub release from the tag — the install snippets in the
   README pin `@main`, but they keep working with tags too.
