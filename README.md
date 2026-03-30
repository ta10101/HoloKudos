# ⚡ HoloKudos

**Decentralized peer recognition built on [Holochain](https://holochain.org).**

Every kudo is signed by your ed25519 agent key and stored permanently on the DHT.
No server. No database. No admin who can delete it. Your reputation is yours.

---

![HoloKudos — Give Kudos](screenshots/app-form.png)

![HoloKudos — Live DHT Feed](screenshots/app-feed.png)

---

## How it works

- **Agent identity** — each user has a cryptographic keypair. Kudos are signed by the giver's private key, so authorship is unforgeable.
- **DHT storage** — kudos are gossiped across peers and stored in the distributed hash table. No central server can delete or censor them.
- **Source chain** — every action is recorded on the author's local chain, providing a tamper-evident history.
- **Validation** — the integrity zome enforces rules at the DNA level. Every peer independently validates entries before accepting them.

## Structure

```
happ/          Rust zomes (integrity + coordinator), DNA + hApp manifests
desktop/       Tauri desktop wrapper — embeds the Holochain conductor
demo/          Interactive browser demo (no conductor required)
```

## Run the demo

Open `demo/index.html` in any browser — no installation needed.

## Build & run the real hApp

Requires: Rust, Node.js, WSL2 (Windows) or Linux/macOS.

```bash
# 1. Install Holochain toolchain (once)
cd happ && ./setup.sh

# 2. Compile zomes, pack DNA + hApp, build Tauri installer
cd ../desktop && ./build.sh

# Output: desktop/src-tauri/target/release/bundle/
#   → HoloKudos_1.0.0_x64-setup.exe  (Windows)
#   → holokudos_1.0.0_amd64.deb      (Linux)
```

## Run locally (no installer)

```bash
cd happ
./setup.sh          # first time only
./build.sh          # compile + pack
./run.sh            # single agent
./run_multi.sh      # two agents — real P2P on localhost
```

Then open `happ/ui/index.html?port=<APP_PORT>` (port printed in terminal).

## Categories

| | |
|---|---|
| 🤝 Collaboration | 💻 Code Quality |
| 🎓 Mentorship | 💡 Innovation |
| 🛠 Helpfulness | 📣 Communication |

## Tech stack

- [Holochain](https://holochain.org) — agent-centric P2P runtime
- [HDK](https://docs.rs/hdk) / [HDI](https://docs.rs/hdi) — Rust zome development kit
- [Tauri](https://tauri.app) — desktop wrapper
- [`@holochain/client`](https://www.npmjs.com/package/@holochain/client) — UI ↔ conductor WebSocket bridge

## License

MIT
