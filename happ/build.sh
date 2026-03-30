#!/usr/bin/env bash
# build.sh — Compile zomes → WASM, package DNA, package hApp
set -e

export PATH="$HOME/.local/bin:$PATH"
cd "$(dirname "$0")"

echo "==> Compiling zomes to WASM..."
cargo build \
  --release \
  --target wasm32-unknown-unknown \
  -p kudos_integrity \
  -p kudos

echo "==> Packaging DNA..."
hc dna pack dna/workdir --output dna/workdir/holokudos.dna

echo "==> Packaging hApp..."
hc app pack workdir --output workdir/holokudos.happ

echo ""
echo "✓ Build done!  workdir/holokudos.happ"
echo "Next: run ./run.sh"
