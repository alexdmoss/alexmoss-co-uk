FROM al3xos/distroless-caddy:2.11@sha256:f3137c8f5fb07a958f63ab6790dd4fc2f3ed96638bed80b8b00e12f73dd80a20
USER nonroot
COPY --chown=nonroot:nonroot Caddyfile /etc/caddy/Caddyfile
COPY --chown=nonroot:nonroot app/ ./app
COPY --chown=nonroot:nonroot xmas/ ./app/xmas
