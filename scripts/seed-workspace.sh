#!/bin/sh
# Seed /data/workspace/{SOUL.md,AGENTS.md} from the image-bundled /workspace-init/
# Run from your local machine once the Railway deploy is GREEN:
#   railway link    # if not already linked to the project
#   railway run sh scripts/seed-workspace.sh
#
# Safe to re-run — won't overwrite existing files.

set -e

mkdir -p /data/workspace

for f in SOUL.md AGENTS.md; do
  if [ -f "/data/workspace/$f" ]; then
    echo "[skip] /data/workspace/$f already exists"
  else
    cp "/workspace-init/$f" "/data/workspace/$f"
    echo "[seed] /data/workspace/$f"
  fi
done

ls -la /data/workspace/
