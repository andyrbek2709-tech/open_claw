FROM ghcr.io/openclaw/openclaw:latest

# Start in local mode so the gateway serves the /setup wizard
# even before a config file exists in OPENCLAW_STATE_DIR.
ENV OPENCLAW_GATEWAY_MODE=local

# Workspace seed files — staged inside the image, can be copied to
# /data/workspace later via `railway run` or the /setup wizard upload.
COPY --chown=node:node workspace/ /workspace-init/

# Railway exposes this port publicly; image's nginx proxies → :18789 (loopback).
EXPOSE 8080
