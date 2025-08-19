This directory stores local development keys for kdapp-mcp-server.

Not committed: avoid placing real/private keys in this repo. Generate test keys using:

  python3 generate_agent_keys.py

The script outputs keys under this directory for local runs. Add patterns to `.gitignore` to protect them.
