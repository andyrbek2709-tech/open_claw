FROM ghcr.io/openclaw/openclaw:latest

# Workspace seed files bundled into the image
COPY --chown=node:node workspace/ /workspace-init/

# Entrypoint: seeds /data/workspace/ on first boot, then starts the gateway
COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8080
