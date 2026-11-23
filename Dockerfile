FROM al3xos/nginx-with-prometheus:1.17-3101490048-2026.11.23.0609
USER nginx
COPY config/default.conf /etc/nginx/conf.d/
COPY app/ /app/
COPY xmas/ /app/xmas/
