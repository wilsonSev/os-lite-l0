#!/bin/sh
# Demo contract only; this is not the H1 course checker.
if [ "$#" -ne 1 ]; then
    echo 'Usage: demo-check.sh src-directory' >&2
    exit 2
fi
if [ ! -f "$1/hello.txt" ] || [ ! -r "$1/hello.txt" ]; then
    echo 'FAIL (demo): src/hello.txt is missing or unreadable' >&2
    exit 1
fi
if printf 'Hello, OS Lite!\n' | cmp -s - "$1/hello.txt"; then
    echo 'PASS (demo): src/hello.txt matches the expected line'
else
    echo 'FAIL (demo): expected exactly Hello, OS Lite! followed by a newline' >&2
    exit 1
fi
