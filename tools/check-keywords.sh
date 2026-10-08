#!/bin/sh
#
# check-keywords.sh -- compare the keyword set in the Vim syntax file with the
# one the Clockwork lexer actually recognises.
#
#   tools/check-keywords.sh [path/to/iod/src/cwlang.lpp]
#
# The lexer, latproc/iod/src/cwlang.lpp, is the authority for the language.  If
# this script reports drift, the syntax file is stale and vi/clockwork/syntax/
# clockwork.vim has to change -- not this script.
#
# Exit status: 0 in sync, 1 drift, 2 the lexer file was not found.
#
set -eu

usage() {
    echo "usage: $0 [path/to/iod/src/cwlang.lpp]" >&2
    exit 2
}

case "${1:-}" in
    -h|--help) usage ;;
esac

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
root=$(dirname -- "$here")
syntax="$root/vi/clockwork/syntax/clockwork.vim"

if [ ! -f "$syntax" ]; then
    echo "$0: cannot find $syntax" >&2
    exit 2
fi

# Where is the lexer?
lexer=${1:-}
if [ -z "$lexer" ]; then
    for candidate in \
        "${LATPROC:-}/iod/src/cwlang.lpp" \
        "${CLOCKWORK:-}/iod/src/cwlang.lpp" \
        "$root/../latproc/iod/src/cwlang.lpp"
    do
        # skip the empty-shell candidates that the unset variables produce
        case "$candidate" in
            /iod/*) continue ;;
        esac
        if [ -f "$candidate" ]; then
            lexer=$candidate
            break
        fi
    done
fi
if [ -z "$lexer" ] || [ ! -f "$lexer" ]; then
    echo "$0: no cwlang.lpp found -- pass the path, or set LATPROC." >&2
    usage
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT INT TERM

# Word spellings in the lexer's rules section: a bare upper case word that
# returns a token or runs an action.  The rules section is between the two
# '%%' markers.
awk '
    /^%%[ \t]*$/ { section++; next }
    section != 1 { next }
    /^[ \t]*IS\[ \]\*NOT[ \t]/ { print "IS"; print "NOT"; next }
    /^[ \t]*[A-Z0-9]/ {
        pattern = $1
        body = $0
        sub(/^[ \t]*[A-Z0-9_]+[ \t]+/, "", body)
        if (body !~ /^return[ \t]/ && body !~ /^\{/) next
        if (pattern ~ /^[0-9]+$/) next          # the 0 integer literal rule
        print pattern
    }
' "$lexer" | sort -u > "$tmp/lexer"

# The words the syntax file highlights out of that lexer list.  cwKeyword and
# cwType and cwDeprecated are the lexer-derived groups; cwConstant and
# cwBuiltin are a different thing (run-time values and classes) and are not
# compared here.
awk '
    /^syn keyword (cwKeyword|cwType|cwDeprecated)([ \t]|$)/ { inblock = 1 }
    inblock && $0 !~ /^[ \t]*\\/ && $0 !~ /^syn keyword / { inblock = 0 }
    inblock {
        line = $0
        sub(/^[ \t]*syn keyword (cwKeyword|cwType|cwDeprecated)/, "", line)
        gsub(/\\/, " ", line)
        n = split(line, word, /[ \t]+/)
        for (i = 1; i <= n; i++) if (word[i] != "") print word[i]
    }
' "$syntax" | sort -u > "$tmp/vim"

missing=$(comm -23 "$tmp/lexer" "$tmp/vim")
extra=$(comm -13 "$tmp/lexer" "$tmp/vim")
stale=$(comm -23 "$tmp/lexer" "$tmp/vim" | wc -l | tr -d ' ')
spurious=$(comm -13 "$tmp/lexer" "$tmp/vim" | wc -l | tr -d ' ')

echo "lexer:  $lexer"
echo "syntax: $syntax"

if [ -z "$missing" ] && [ -z "$extra" ]; then
    echo "OK: $(wc -l < "$tmp/vim" | tr -d ' ') keywords, in sync with the lexer"
    exit 0
fi

if [ -n "$missing" ]; then
    echo
    echo "$stale keyword(s) in the language but not in the syntax file:"
    echo "$missing" | sed 's/^/    /'
fi
if [ -n "$extra" ]; then
    echo
    echo "$spurious word(s) in the syntax file that the lexer does not know:"
    echo "$extra" | sed 's/^/    /'
fi
exit 1
