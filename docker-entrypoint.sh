#!/bin/sh
# Runs as root.
# 1. Fixes /data ownership so the node user can write (Railway mounts as root).
# 2. Seeds /data/workspace with persona files.
# 3. Writes a gateway config to /tmp with the Railway public domain in allowedOrigins.
# 4. Drops privileges to node via gosu and execs the gateway.

# ── Fix /data volume ownership ────────────────────────────────────────────────
chown node:node /data 2>/dev/null \
  && echo "[openclaw-init] /data ownership set to node" \
  || echo "[openclaw-init] WARN: could not chown /data ($(ls -ld /data 2>&1))"

# ── Seed workspace files ──────────────────────────────────────────────────────
if mkdir -p /data/workspace 2>/dev/null; then
  [ -f /data/workspace/SOUL.md ]   || cp /workspace-init/SOUL.md   /data/workspace/SOUL.md   2>/dev/null
  [ -f /data/workspace/AGENTS.md ] || cp /workspace-init/AGENTS.md /data/workspace/AGENTS.md 2>/dev/null
  chown -R node:node /data/workspace 2>/dev/null || true
  echo "[openclaw-init] /data/workspace seeded: $(ls /data/workspace/ 2>&1)"
else
  echo "[openclaw-init] WARN: could not create /data/workspace"
fi

# ── Write gateway config with Railway's public domain in allowedOrigins ───────
# RAILWAY_PUBLIC_DOMAIN is auto-injected by Railway (e.g. myapp.up.railway.app)
ORIGIN_LIST='"http://localhost:*","https://localhost:*"'
if [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  ORIGIN_LIST="${ORIGIN_LIST},\"https://${RAILWAY_PUBLIC_DOMAIN}\""
  echo "[openclaw-init] Adding allowed Control UI origin: https://${RAILWAY_PUBLIC_DOMAIN}"
fi
if [ -n "$OPENCLAW_EXTRA_ALLOWED_ORIGIN" ]; then
  ORIGIN_LIST="${ORIGIN_LIST},\"${OPENCLAW_EXTRA_ALLOWED_ORIGIN}\""
fi

cat > /tmp/openclaw-init.json << _CFG_
{
  "gateway": {
    "controlUi": {
      "allowedOrigins": [${ORIGIN_LIST}]
    },
    "trustedProxies": ["100.64.0.0/10", "127.0.0.1", "::1"]
  }
}
_CFG_
export OPENCLAW_CONFIG_PATH=/tmp/openclaw-init.json
echo "[openclaw-init] gateway config: $(cat /tmp/openclaw-init.json)"

# ── Drop privileges and exec gateway ─────────────────────────────────────────
if command -v gosu >/dev/null 2>&1; then
  exec gosu node openclaw gateway --allow-unconfigured
else
  echo "[openclaw-init] WARN: gosu not found — running gateway as current user"
  exec openclaw gateway --allow-unconfigured
fi
