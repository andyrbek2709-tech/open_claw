#!/bin/sh
set -e

# Initialise persistent volume structure on first deploy
mkdir -p /data/.openclaw /data/workspace

# Seed workspace context files only if not already present
for f in SOUL.md AGENTS.md; do
  if [ ! -f "/data/workspace/$f" ]; then
    cp "/workspace-init/$f" "/data/workspace/$f"
    echo "[openclaw-init] seeded /data/workspace/$f"
  fi
done

# Hand off to the original image entrypoint / CMD
exec "$@"
