FROM al3xos/distroless-caddy:2.10.2
USER nonroot
COPY --chown=nonroot:nonroot Caddyfile /etc/caddy/Caddyfile
COPY --chown=nonroot:nonroot app/ ./app
