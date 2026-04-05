FROM alpine:3.19

RUN apk add --no-cache \
    git \
    build-base \
    linux-headers \
    nginx \
    iproute2 \
    iptables \
    net-tools

RUN git clone https://github.com/Friedrich/hans.git /tmp/hans \
    && cd /tmp/hans && make && cp hans /usr/local/bin/hans \
    && rm -rf /tmp/hans

RUN mkdir -p /usr/share/nginx/html && \
    echo '<html><body><h1>Hans ICMP Tunnel OK</h1><p>Conexion via tunel ICMP funcionando.</p></body></html>' \
    > /usr/share/nginx/html/index.html && \
    printf 'server {\n    listen 80;\n    root /usr/share/nginx/html;\n    index index.html;\n    location / { try_files $uri $uri/ =404; }\n}\n' \
    > /etc/nginx/http.d/default.conf

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]