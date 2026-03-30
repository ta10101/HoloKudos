#!/usr/bin/env bash
# setup.sh — Install Holochain toolchain into WSL2 (run once)
set -e

HOLOCHAIN_VERSION="0.4.0-rc.4"
HC_VERSION="0.4.0-rc.4"
LAIR_VERSION="0.4.5"

BASE="https://github.com/holochain/holochain/releases/download"
LAIR_BASE="https://github.com/holochain/lair/releases/download"
BIN="$HOME/.local/bin"
mkdir -p "$BIN"

echo "==> Adding Rust wasm32 target..."
rustup target add wasm32-unknown-unknown

echo "==> Downloading holochain $HOLOCHAIN_VERSION..."
curl -L "$BASE/holochain-$HOLOCHAIN_VERSION/holochain-x86_64-unknown-linux-musl.tar.gz" \
  | tar xz -C "$BIN"

echo "==> Downloading hc CLI $HC_VERSION..."
curl -L "$BASE/holochain-$HOLOCHAIN_VERSION/hc-x86_64-unknown-linux-musl.tar.gz" \
  | tar xz -C "$BIN"

echo "==> Downloading lair-keystore $LAIR_VERSION..."
curl -L "$LAIR_BASE/v$LAIR_VERSION/lair-keystore-v${LAIR_VERSION}-x86_64-unknown-linux-musl.tar.gz" \
  | tar xz -C "$BIN"

chmod +x "$BIN/holochain" "$BIN/hc" "$BIN/lair-keystore"

# Make sure ~/.local/bin is on PATH
if ! grep -q 'local/bin' ~/.bashrc; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi
export PATH="$BIN:$PATH"

echo ""
echo "✓ Setup complete!"
echo "  holochain: $(holochain --version)"
echo "  hc:        $(hc --version)"
echo ""
echo "Next: run ./build.sh"
