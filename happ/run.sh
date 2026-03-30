#!/usr/bin/env bash
# run.sh — Spin up a local Holochain sandbox with the hApp installed.
#          The UI serves on port 8080. Multiple peers = run in separate terminals.
set -e

export PATH="$HOME/.local/bin:$PATH"
cd "$(dirname "$0")"

HAPP="workdir/holokudos.happ"

if [ ! -f "$HAPP" ]; then
  echo "hApp not built yet. Run: ./build.sh"
  exit 1
fi

# hc sandbox create+run in one command.
# It prints the app websocket port — the UI reads it via ?port=XXXX
echo "==> Starting Holochain sandbox..."
echo "    The app WebSocket port will be printed below."
echo "    Open ui/index.html?port=<APP_PORT> in your browser."
echo ""

hc sandbox --piped create --app-id holokudos "$HAPP"

# Get the sandbox name (last created)
SANDBOX=$(ls -td ~/.config/holochain/sandbox/*/  | head -1)
echo "Sandbox: $SANDBOX"

hc sandbox run --piped -e "$SANDBOX"
