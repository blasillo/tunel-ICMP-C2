FROM alpine:3.19

RUN apk add --no-cache \
    git \
    build-base \
    linux-headers \
    python3 \
    py3-pip \
    iproute2 \
    iptables \
    net-tools

RUN pip3 install flask --break-system-packages

RUN git clone https://github.com/Friedrich/hans.git /tmp/hans \
    && cd /tmp/hans && make && cp hans /usr/local/bin/hans \
    && rm -rf /tmp/hans

COPY app.py /app.py
COPY entrypoint.sh /entrypoint.sh
RUN sed -i 's/\r//' /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]