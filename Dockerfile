FROM ghcr.io/openclaw/openclaw:latest

# Run as root so the entrypoint can chown /data and install gosu
USER root

# Install gosu for privilege-dropping (node user can't sudo; gosu passes env cleanly)
RUN (command -v gosu >/dev/null 2>&1) \
    || (apt-get update -qq && apt-get install -y --no-install-recommends gosu && rm -rf /var/lib/apt/lists/*) \
    || (apk add --no-cache gosu 2>/dev/null) \
    || true

# Workspace seed files bundled into the image
COPY --chown=node:node workspace/ /workspace-init/

# Entrypoint: fixes /data ownership, seeds workspace, starts gateway as node
COPY --chmod=755 docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 8080
