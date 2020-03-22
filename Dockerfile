FROM alpine

LABEL maintainer="Howtin <gonghao@ghsky.com>"

ENV BINARY_URL 'https://github.com/surge-networks/snell/releases/download/2.0.0b1/snell-server-v2.0.0-linux-amd64.zip'

RUN set -ex \
    # Install dependencies
    && apk add --no-cache --virtual .build-deps \
               wget \
               unzip \
    && wget -O /tmp/snell-server.zip ${BINARY_URL} \
    && unzip /tmp/snell-server.zip -d /usr/local/bin \
    && rm -f /tmp/snell-server.zip \
    # Delete dependencies
    && apk del .build-deps

# Snell-server environment variables
ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 49216
ENV PSK ChangeMe!!!
ENV OBFS http
ENV ARGS ""

RUN set -ex \
    # Genergate config file
    && mkdir /config \
    && echo $'[snell-server]\n\
listen = '${SERVER_ADDR}$':'${SERVER_PORT}$'\n\
psk = '${PSK}$'\n\
obfs = '${OBFS}\
        > /config/snell-server.conf

RUN cat /config/snell-server.conf

EXPOSE $SERVER_PORT/tcp

# Run as nobody
USER nobody

# Start shadowsocks-libev server
CMD exec snell-server \
    -c /config/snell-server.conf \
    $ARGS
