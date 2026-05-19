#!/bin/sh
set -e

# Seed workspace context files on first boot (idempotent)
mkdir -p /data/workspace
[ -f /data/workspace/SOUL.md ]   || cp /workspace-init/SOUL.md   /data/workspace/SOUL.md
[ -f /data/workspace/AGENTS.md ] || cp /workspace-init/AGENTS.md /data/workspace/AGENTS.md

echo "[openclaw-init] workspace ready: $(ls /data/workspace/)"

# Start the gateway
exec openclaw gateway --allow-unconfigured
