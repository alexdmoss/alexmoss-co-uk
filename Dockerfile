FROM al3xos/distroless-caddy:2.9.1
COPY --chown=nonroot:nonroot Caddyfile /etc/caddy/Caddyfile
COPY --chown=nonroot:nonroot app/ ./app
