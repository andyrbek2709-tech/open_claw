FROM ghcr.io/openclaw/openclaw:latest

# Workspace seed files — staged inside the image, can be copied to
# /data/workspace later via `railway run` or the /setup wizard upload.
COPY --chown=node:node workspace/ /workspace-init/

# Railway exposes this port publicly; image's nginx proxies → :18789 (loopback).
EXPOSE 8080
