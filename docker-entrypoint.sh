#!/bin/sh
# Best-effort workspace seed.
# /data is owned by root on first mount; if the gateway user can't write to
# /data, just skip — workspace files can be uploaded via the Control UI later.

if mkdir -p /data/workspace 2>/dev/null; then
  [ -f /data/workspace/SOUL.md ]   || cp /workspace-init/SOUL.md   /data/workspace/SOUL.md   2>/dev/null
  [ -f /data/workspace/AGENTS.md ] || cp /workspace-init/AGENTS.md /data/workspace/AGENTS.md 2>/dev/null
  echo "[openclaw-init] /data/workspace seeded: $(ls /data/workspace/ 2>&1)"
else
  echo "[openclaw-init] WARN: /data not writable by $(id -un 2>/dev/null || echo unknown); skipping seed (upload SOUL.md and AGENTS.md via Control UI)"
fi

# Hand off to the gateway — must succeed for the deploy to be green
exec openclaw gateway --allow-unconfigured
