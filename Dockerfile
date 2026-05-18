FROM ghcr.io/openclaw/openclaw:latest

# Workspace init files — copied to /data/workspace on first boot (if absent)
COPY --chown=node:node workspace/ /workspace-init/

# Entrypoint wrapper initialises /data dirs, then chains to the image's CMD
COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

# Railway exposes this port publicly; nginx inside the image proxies → :18789
EXPOSE 8080
