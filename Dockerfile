FROM frolvlad/alpine-glibc

LABEL maintainer="Howtin <gonghao@ghsky.com>"

ENV SNELL_VERSION 2.0.0
ENV SNELL_TAG 2.0.0b1

RUN set -ex \
    # Install dependencies
    && apk add --no-cache --virtual .build-deps \
                wget \
                unzip \
                ca-certificates \
    && wget -O snell-server.zip "https://github.com/surge-networks/snell/releases/download/${SNELL_TAG}/snell-server-v${SNELL_VERSION}-linux-amd64.zip" \
    && unzip snell-server.zip \
    && mv snell-server /usr/local/bin \
    && rm -f snell-server.zip \
    && apk add --no-cache --virtual .snell-rundeps \
                libstdc++ \
    # Delete dependencies
    && apk del .build-deps

# Snell-server environment variables
ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 49216
ENV PSK ChangeMe!!!
ENV OBFS http
ENV ARGS=

RUN set -ex \
    # Genergate config file
    && mkdir /config \
    && echo $'[snell-server]\n\
listen = '${SERVER_ADDR}$':'${SERVER_PORT}$'\n\
psk = '${PSK}$'\n\
obfs = '${OBFS}\
        > /config/snell-server.conf

EXPOSE $SERVER_PORT/tcp

# Run as nobody
USER nobody

# Start shadowsocks-libev server
CMD exec snell-server \
    -c /config/snell-server.conf \
    $ARGS
