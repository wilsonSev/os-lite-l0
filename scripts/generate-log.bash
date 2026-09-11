#!/usr/bin/env bash
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
[ -f logs/myitmo.log ] || { echo 'Run ./setup first.' >&2; exit 2; }
mkdir -p .runtime
if ! mkdir .runtime/log.lock 2>/dev/null; then
    echo 'Generator/reset already running, or stale lock (see README).' >&2
    exit 2
fi
trap 'rmdir "$ROOT/.runtime/log.lock"' EXIT
trap 'exit 0' INT TERM
printf '%s\n' 'Writing one event per second; stop with Ctrl-C or kill the background job.' >&2
# Replay the final 10 events; only timestamps depend on the current UTC time.
while :; do
    tail -n 10 fixtures/myitmo.log.initial | while IFS= read -r line; do
        sleep 1
        printf '%s %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "${line#* }" >> logs/myitmo.log
    done
done
