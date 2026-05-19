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

# Build a gateway config that explicitly allows the Railway public domain.
# RAILWAY_PUBLIC_DOMAIN is auto-injected by Railway (e.g. "myapp.up.railway.app").
# We write to /tmp which is always writable, then point OPENCLAW_CONFIG_PATH at it.
ORIGIN_LIST='"http://localhost:*","https://localhost:*"'
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  ORIGIN_LIST="${ORIGIN_LIST},\"https://${RAILWAY_PUBLIC_DOMAIN}\""
  echo "[openclaw-init] Adding allowed Control UI origin: https://${RAILWAY_PUBLIC_DOMAIN}"
fi
# Also honour an explicit extra origin override
if [ -n "$OPENCLAW_EXTRA_ALLOWED_ORIGIN" ]; then
  ORIGIN_LIST="${ORIGIN_LIST},\"${OPENCLAW_EXTRA_ALLOWED_ORIGIN}\""
fi

cat > /tmp/openclaw-init.json << _CFG_
{
  "gateway": {
    "controlUi": {
      "allowedOrigins": [${ORIGIN_LIST}]
    }
  }
}
_CFG_
export OPENCLAW_CONFIG_PATH=/tmp/openclaw-init.json
echo "[openclaw-init] gateway config: $(cat /tmp/openclaw-init.json)"

# Hand off to the gateway — must succeed for the deploy to be green
exec openclaw gateway --allow-unconfigured
