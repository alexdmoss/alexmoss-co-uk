FROM al3xos/nginx-with-prometheus:1.7
COPY config/default.conf config/redirects.include /etc/nginx/conf.d/
COPY www/ /app/
