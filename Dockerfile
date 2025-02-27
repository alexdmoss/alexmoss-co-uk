FROM al3xos/distroless-caddy:2.9.1
COPY Caddyfile /etc/caddy/Caddyfile
COPY app/ ./app
