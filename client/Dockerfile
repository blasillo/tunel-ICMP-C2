FROM alpine:3.19

RUN apk add --no-cache \
    git \
    build-base \
    linux-headers \
    curl \
    iproute2 \
    net-tools \
    iputils

RUN git clone https://github.com/Friedrich/hans.git /tmp/hans \
    && cd /tmp/hans && make && cp hans /usr/local/bin/hans \
    && rm -rf /tmp/hans

COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r//' /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]