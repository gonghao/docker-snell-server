FROM frolvlad/alpine-glibc

LABEL maintainer="Howtin <gonghao@ghsky.com>"

ENV SNELL_VERSION 2.0.0-b12
ENV SNELL_TAG 2.0.0b12

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
ENV SERVER_PORT 49216
ENV ARGS=

EXPOSE $SERVER_PORT/tcp

# Run as nobody
USER nobody

# Start snell-server
CMD exec snell-server \
    -c /config/snell-server.conf \
    $ARGS
