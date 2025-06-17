FROM al3xos/distroless-caddy:2.10.0
USER nonroot
COPY --chown=nonroot:nonroot Caddyfile /etc/caddy/Caddyfile
COPY --chown=nonroot:nonroot app/ ./app
