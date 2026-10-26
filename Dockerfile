FROM al3xos/distroless-caddy:2.11@sha256:371a1acb7d47a922009717edb7f56545a5d7b76cf123d420b6f435ccbff37744
USER nonroot
COPY --chown=nonroot:nonroot Caddyfile /etc/caddy/Caddyfile
COPY --chown=nonroot:nonroot app/ ./app
COPY --chown=nonroot:nonroot xmas/ ./app/xmas
