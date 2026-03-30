#!/usr/bin/env bash
# run_multi.sh — Launch 2 sandboxes to simulate a real P2P network locally.
#                Each gets its own port and agent key.
set -e

export PATH="$HOME/.local/bin:$PATH"
cd "$(dirname "$0")"

HAPP="workdir/holokudos.happ"
[ ! -f "$HAPP" ] && echo "Run ./build.sh first" && exit 1

echo "==> Creating 2-agent sandbox..."
hc sandbox --piped create -n 2 --app-id holokudos "$HAPP"

echo ""
echo "==> Starting both agents. Two different conductor ports will appear."
echo "    Open ui/index.html?port=<PORT1> and ui/index.html?port=<PORT2>"
echo "    in two browser tabs — they'll share the same DHT."
echo ""

hc sandbox run --piped -e all
