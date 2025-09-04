Local TODO — Step 2 follow-ups (do not commit)

This file is intentionally local-only to avoid conflicts when syncing with codex-1. Add it to .gitignore if not already ignored.

Planned items
- On-chain submit CLI: add a `send-onchain` flow using `kdapp::generator::TransactionGenerator` to pack `EpisodeMessage` payloads and broadcast via Kaspad. Include flags: `--wrpc-url`, `--mainnet`, basic fee control, and a minimal UTXO selection for signing.
- Graceful shutdown: in proxy mode, handle Ctrl‑C (`tokio::signal::ctrl_c`) to set the `exit` flag passed to `kdapp::proxy::run_listener` so it exits cleanly.
- Routing overrides: allow independent `--prefix` or `--pattern` overrides; derive whichever is not provided. Validate `--pattern` format `pos:bit` with `pos` 0–255 and `bit` 0/1.
- Pattern quality: ensure 10 distinct bit positions in the derived `PatternType` to maximize selectivity and reduce accidental matches.
- Key parsing: accept `0x`‑prefixed merchant private keys and surface clear errors on invalid hex/length.
- Storage config: add `--db-path` (and optional `MERCHANT_DB_PATH`) to control sled database location; default remains `./merchant.db`.
- Docs/examples: include a concrete example of derived prefix/pattern for a fixed pubkey and a short how‑to for composing `--pattern` strings.

Scratch notes
- Consider a `--dry-run` flag for on-chain submission that prints the tx id and derived routing ids without broadcasting.
- Optional: add `--pattern-file`/`--prefix-file` to load overrides from a file for deployments.
