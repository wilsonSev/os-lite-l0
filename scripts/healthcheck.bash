#!/usr/bin/env bash
# Offline log inspection, NOT an HTTP health probe.
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd) || exit 2
if [ "$#" -gt 1 ]; then
    echo 'Usage: healthcheck.bash [log-file]' >&2
    exit 2
fi
log=${1:-"$ROOT/logs/myitmo.log"}
if [ ! -f "$log" ] || [ ! -r "$log" ] || [ ! -s "$log" ]; then
    echo 'UNKNOWN: log must be a readable nonempty file' >&2
    exit 2
fi
grep -q ' ERROR ' "$log"
status=$?
case "$status" in
    0) echo 'FAIL: ERROR events found in log' >&2; exit 1 ;;
    1) echo 'OK: no ERROR events in log'; exit 0 ;;
    *) echo 'UNKNOWN: cannot inspect log' >&2; exit 2 ;;
esac
