#!/usr/bin/env zsh
# tests/test-mdview.zsh — exercise bin/mdview end-to-end.
#
# Run:  zsh tests/test-mdview.zsh
# Exit: 0 on full pass, non-zero on failure.

emulate -L zsh
set -euo pipefail

REPO_ROOT=${0:A:h:h}
MDVIEW="${MDVIEW_BIN:-$REPO_ROOT/bin/mdview}"

PASS=0
FAIL=0
typeset -a ERRORS
ERRORS=()

pass() { PASS=$((PASS + 1)); print -r -- "  ✓ $1"; }
fail() {
    FAIL=$((FAIL + 1))
    ERRORS+=("$1")
    print -ru2 -- "  ✗ $1"
}

assert_contains() {
    case "$1" in
        *"$2"*) pass "$3" ;;
        *) fail "$3 — expected to contain [$2]" ;;
    esac
}

assert_not_contains() {
    case "$1" in
        *"$2"*) fail "$3 — should not contain [$2]" ;;
        *) pass "$3" ;;
    esac
}

# Sandbox: redirect `open` so the suite doesn't actually launch a browser.
TMPROOT=$(mktemp -d)
trap 'rm -rf "$TMPROOT"' EXIT

FAKE_BIN="$TMPROOT/bin"
mkdir -p "$FAKE_BIN"
cat >"$FAKE_BIN/open" <<'STUB'
#!/usr/bin/env zsh
print -r -- "open $*" >> "$OPEN_LOG"
STUB
chmod +x "$FAKE_BIN/open"
export OPEN_LOG="$TMPROOT/open.log"
: >"$OPEN_LOG"
export PATH="$FAKE_BIN:$PATH"

# Sample markdown with edge-case content: code fences, inline HTML-ish
# fragments, and a literal "</script>" sequence that would break a naive
# script-tag embedding.
SAMPLE="$TMPROOT/sample.md"
cat >"$SAMPLE" <<'MD'
# Hello mdview

A *paragraph* with **bold** and `inline code`.

```js
function f(x) { return x + 1; }
console.log("</script>"); // tricky terminator
```

- list item one
- list item two

> blockquote with `<div>` inline

[link](https://example.com)
MD

# Sample MDX: ESM import/export lines, an inline component, a JS expression,
# JSX usage, and a tricky </script> inside a fenced code block.
MDX_SAMPLE="$TMPROOT/sample.mdx"
cat >"$MDX_SAMPLE" <<'MDX'
import Chart from './chart'
export const Box = (props) => <strong>{props.children}</strong>

# MDX Heading

A paragraph mentioning wombat plainly.

Two plus two is {2 + 2} and here is a <Box>boxed</Box> word.

<Chart/>

```js
console.log("</script>"); // tricky terminator
```
MDX

# -----------------------------------------------------------------
print "== script exists & executable =="
# -----------------------------------------------------------------
if [[ -x "$MDVIEW" ]]; then pass "mdview executable"
else fail "mdview missing or not executable: $MDVIEW"; fi

# -----------------------------------------------------------------
print "== zsh -n parses =="
# -----------------------------------------------------------------
if zsh -n "$MDVIEW" 2>/dev/null; then
    pass "mdview parses (zsh -n)"
else
    fail "mdview has syntax errors"
fi

# -----------------------------------------------------------------
print "== --help prints usage =="
# -----------------------------------------------------------------
HELP=$("$MDVIEW" --help)
assert_contains "$HELP" "mdview" "help mentions mdview"
assert_contains "$HELP" "FILE" "help shows positional FILE"
assert_contains "$HELP" "--browser" "help lists --browser"
assert_contains "$HELP" "--terminal" "help lists --terminal"
assert_contains "$HELP" "--print" "help lists --print"
assert_contains "$HELP" "--version" "help lists --version"

# -----------------------------------------------------------------
print "== --version prints version =="
# -----------------------------------------------------------------
VER=$("$MDVIEW" --version)
assert_contains "$VER" "mdview" "version line mentions mdview"
case "$VER" in
    *[0-9]*) pass "version line contains a digit" ;;
    *) fail "version line missing digit: $VER" ;;
esac

# -----------------------------------------------------------------
print "== no args fails (exit 2) =="
# -----------------------------------------------------------------
if "$MDVIEW" >/dev/null 2>&1; then
    fail "no-args call should fail"
else
    rc=$?
    if [[ "$rc" = "2" ]]; then pass "no-args exits 2"
    else fail "no-args exit code expected 2, got $rc"; fi
fi

# -----------------------------------------------------------------
print "== unknown flag fails =="
# -----------------------------------------------------------------
if "$MDVIEW" --bogus >/dev/null 2>&1; then
    fail "unknown flag should fail"
else
    pass "unknown flag rejected"
fi

# -----------------------------------------------------------------
print "== missing file fails =="
# -----------------------------------------------------------------
if "$MDVIEW" "$TMPROOT/does-not-exist.md" --print >/dev/null 2>&1; then
    fail "missing file should fail"
else
    pass "missing file rejected"
fi

# -----------------------------------------------------------------
print "== --print produces full HTML doc =="
# -----------------------------------------------------------------
HTML=$("$MDVIEW" "$SAMPLE" --print)
assert_contains "$HTML" "<!DOCTYPE html>" "print: starts with doctype"
assert_contains "$HTML" "<title>sample.md</title>" "print: title is filename"
assert_contains "$HTML" "github-markdown" "print: includes github-markdown css"

# Without pandoc, the marked.js fallback is used. Verify embedded markdown
# is HTML-escaped inside the textarea so </script> in content can't break out.
if ! (( $+commands[pandoc] )); then
    assert_contains "$HTML" "id=\"md-source\"" "print: marked fallback embeds textarea"
    assert_contains "$HTML" "marked.parse" "print: invokes marked.parse"
    # textarea_escape only converts & and <, so > stays literal — that's fine
    # because </textarea> is the only sequence that could close the host tag,
    # and we've broken it by escaping the leading <.
    assert_contains "$HTML" "&lt;/script>" "print: tricky </script> escaped to &lt;/"
    assert_not_contains "$HTML" "console.log(\"</script>\")" \
        "print: literal </script> not present in output"
fi

# -----------------------------------------------------------------
print "== --print honours --title override =="
# -----------------------------------------------------------------
HTML2=$("$MDVIEW" "$SAMPLE" --print --title "Custom & <Title>")
assert_contains "$HTML2" "<title>Custom &amp; &lt;Title&gt;</title>" \
    "title override is HTML-escaped"

# -----------------------------------------------------------------
print "== stdin via '-' works =="
# -----------------------------------------------------------------
HTML3=$(print -rn -- "# from stdin\n\nhi" | "$MDVIEW" - --print)
assert_contains "$HTML3" "<title>stdin</title>" "stdin: title defaults to 'stdin'"
if ! (( $+commands[pandoc] )); then
    assert_contains "$HTML3" "from stdin" "stdin: content embedded"
fi

# -----------------------------------------------------------------
print "== --output writes to specified path and prints it =="
# -----------------------------------------------------------------
OUTPATH="$TMPROOT/out.html"
RESULT=$("$MDVIEW" "$SAMPLE" --output "$OUTPATH" --no-open)
if [[ -f "$OUTPATH" ]]; then pass "output file created"
else fail "output file not created at $OUTPATH"; fi
if [[ "$RESULT" = "$OUTPATH" ]]; then pass "output path printed to stdout"
else fail "expected stdout '$OUTPATH', got '$RESULT'"; fi
# Browser stub should NOT have been called with --no-open.
if ! grep -q "$OUTPATH" "$OPEN_LOG" 2>/dev/null; then
    pass "--no-open suppresses browser launch"
else
    fail "--no-open should not call open"
fi

# -----------------------------------------------------------------
print "== default mode launches browser via open =="
# -----------------------------------------------------------------
: >"$OPEN_LOG"
RESULT=$("$MDVIEW" "$SAMPLE")
if [[ -f "$RESULT" ]]; then pass "default writes a temp html file"
else fail "default did not produce a file: $RESULT"; fi
if grep -q "$RESULT" "$OPEN_LOG"; then
    pass "default invokes open on output path"
else
    fail "default did not invoke open (log: $(cat "$OPEN_LOG"))"
fi

# -----------------------------------------------------------------
print "== --app passes -a APPNAME to open =="
# -----------------------------------------------------------------
: >"$OPEN_LOG"
"$MDVIEW" "$SAMPLE" --app "Google Chrome" >/dev/null
if grep -q -- "-a Google Chrome" "$OPEN_LOG"; then
    pass "--app forwards -a to open"
else
    fail "--app did not forward -a (log: $(cat "$OPEN_LOG"))"
fi

# -----------------------------------------------------------------
print "== terminal mode does not launch browser =="
# -----------------------------------------------------------------
: >"$OPEN_LOG"
"$MDVIEW" "$SAMPLE" --terminal >/dev/null 2>&1 || true
if [[ ! -s "$OPEN_LOG" ]]; then
    pass "terminal mode skips open"
else
    fail "terminal mode should not call open (log: $(cat "$OPEN_LOG"))"
fi

# -----------------------------------------------------------------
print "== .mdx auto-detects MDX render path =="
# -----------------------------------------------------------------
MDXHTML=$("$MDVIEW" "$MDX_SAMPLE" --print)
assert_contains "$MDXHTML" "<!DOCTYPE html>" "mdx: starts with doctype"
assert_contains "$MDXHTML" "<title>sample.mdx</title>" "mdx: title is filename"
assert_contains "$MDXHTML" "esm.sh/@mdx-js/mdx" "mdx: loads @mdx-js/mdx"
assert_contains "$MDXHTML" "evaluate(raw" "mdx: invokes MDX evaluate"
assert_contains "$MDXHTML" "react/jsx-runtime" "mdx: wires react jsx-runtime"
assert_contains "$MDXHTML" "type=\"importmap\"" "mdx: emits an import map"
assert_contains "$MDXHTML" "id=\"md-source\"" "mdx: embeds source textarea"
assert_contains "$MDXHTML" "github-markdown" "mdx: includes github-markdown css"

# Security property must survive the MDX path too: a literal </script> in the
# source is escaped inside the textarea and never appears verbatim.
assert_contains "$MDXHTML" "&lt;/script>" "mdx: tricky </script> escaped to &lt;/"
assert_not_contains "$MDXHTML" "console.log(\"</script>\")" \
    "mdx: literal </script> not present in output"

# -----------------------------------------------------------------
print "== --mdx forces MDX for stdin =="
# -----------------------------------------------------------------
MDXSTDIN=$(print -rn -- "# hi\n\n{1+1}" | "$MDVIEW" - --mdx --print)
assert_contains "$MDXSTDIN" "esm.sh/@mdx-js/mdx" "stdin --mdx: uses MDX path"
assert_contains "$MDXSTDIN" "<title>stdin</title>" "stdin --mdx: title defaults to stdin"

# -----------------------------------------------------------------
print "== --md forces plain markdown on a .mdx file =="
# -----------------------------------------------------------------
MDXOFF=$("$MDVIEW" "$MDX_SAMPLE" --md --print)
assert_not_contains "$MDXOFF" "esm.sh/@mdx-js/mdx" "mdx --md: skips MDX path"
assert_contains "$MDXOFF" "<title>sample.mdx</title>" "mdx --md: title still filename"
if ! (( $+commands[pandoc] )); then
    assert_contains "$MDXOFF" "marked.parse" "mdx --md: falls back to marked"
fi

# -----------------------------------------------------------------
print "== auto temp filename strips the .mdx extension =="
# -----------------------------------------------------------------
: >"$OPEN_LOG"
MDXOUT=$("$MDVIEW" "$MDX_SAMPLE" --no-open)
case "$MDXOUT" in
    *.mdx.html) fail "mdx: temp name kept .mdx ($MDXOUT)" ;;
    *sample.html) pass "mdx: temp name is sample.html" ;;
    *) fail "mdx: unexpected temp name ($MDXOUT)" ;;
esac

# -----------------------------------------------------------------
print "== terminal mode strips MDX import/export lines =="
# -----------------------------------------------------------------
# Renderer-agnostic: we strip the ESM lines from the input before piping, so
# they cannot appear regardless of which terminal renderer (or pager) runs.
MDXTERM=$(PAGER="cat" "$MDVIEW" "$MDX_SAMPLE" --terminal 2>&1 || true)
assert_not_contains "$MDXTERM" "import Chart from" "mdx -t: import line stripped"
assert_not_contains "$MDXTERM" "export const Box" "mdx -t: export line stripped"
assert_contains "$MDXTERM" "wombat" "mdx -t: prose content retained"

# -----------------------------------------------------------------
print
if (( FAIL == 0 )); then
    printf '== all %d checks passed ==\n' "$PASS"
    exit 0
else
    print -ru2 -- "== ${PASS} passed, ${FAIL} failed =="
    for e in "${ERRORS[@]}"; do print -ru2 -- "  - $e"; done
    exit 1
fi
