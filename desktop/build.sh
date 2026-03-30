#!/usr/bin/env bash
# build.sh — One command: compile zomes → pack hApp → build Tauri installer
# Run from WSL2 or Linux. Requires: rust, node, wasm32 target, holochain CLI.
set -e

export PATH="$HOME/.local/bin:$PATH"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HAPP_DIR="$ROOT/happ"
DESKTOP_DIR="$ROOT/desktop"

echo "━━━ Step 1: Compile zomes to WASM ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
rustup target add wasm32-unknown-unknown 2>/dev/null
cargo build \
  --release \
  --target wasm32-unknown-unknown \
  --manifest-path "$HAPP_DIR/Cargo.toml" \
  -p kudos_integrity \
  -p kudos

echo "━━━ Step 2: Pack DNA + hApp ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
hc dna pack "$HAPP_DIR/dna/workdir" --output "$HAPP_DIR/dna/workdir/holokudos.dna"
hc app pack "$HAPP_DIR/workdir"     --output "$HAPP_DIR/workdir/holokudos.happ"
echo "  → $HAPP_DIR/workdir/holokudos.happ"

echo "━━━ Step 3: Download conductor binaries (if needed) ━━━━━━━━━━━━━━━"
BIN="$HAPP_DIR/bin"
mkdir -p "$BIN"

HC_VER="0.4.0-rc.4"
LAIR_VER="0.4.5"
BASE="https://github.com/holochain/holochain/releases/download/holochain-$HC_VER"
LAIR_BASE="https://github.com/holochain/lair/releases/download/v$LAIR_VER"

[ ! -f "$BIN/holochain" ] && \
  curl -sL "$BASE/holochain-x86_64-unknown-linux-musl.tar.gz" | tar xz -C "$BIN"

[ ! -f "$BIN/lair-keystore" ] && \
  curl -sL "$LAIR_BASE/lair-keystore-v${LAIR_VER}-x86_64-unknown-linux-musl.tar.gz" | tar xz -C "$BIN"

# Windows binaries (for bundling into the .exe installer)
[ ! -f "$BIN/holochain.exe" ] && \
  curl -sL "$BASE/holochain-x86_64-pc-windows-msvc.zip" -o /tmp/hc.zip && unzip -q /tmp/hc.zip -d "$BIN"

[ ! -f "$BIN/lair-keystore.exe" ] && \
  curl -sL "$LAIR_BASE/lair-keystore-v${LAIR_VER}-x86_64-pc-windows-msvc.zip" -o /tmp/lair.zip && unzip -q /tmp/lair.zip -d "$BIN"

echo "━━━ Step 4: Build Tauri desktop app ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$DESKTOP_DIR"
npm install --silent
npm run build

echo ""
echo "✅ Done! Installer:"
find "$DESKTOP_DIR/src-tauri/target/release/bundle" -name "*.exe" -o -name "*.msi" -o -name "*.deb" -o -name "*.dmg" 2>/dev/null
echo ""
echo "Share that file — users just double-click to install."
