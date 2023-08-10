FROM debian:bullseye-slim as builder

ARG UID=1501 \
    GID=1501 \
    DIR=/app

COPY nginx_build /nginx_build

WORKDIR /nginx_build/nginx-1.20.2/

RUN apt-get update && \
    apt-get install -y make patch procps gcc g++ libpcre3 libpcre3-dev zlib1g zlib1g-dev openssl libssl-dev build-essential && \
    ./configure --prefix=$DIR/nginx --with-compat --with-file-aio --with-threads --with-http_ssl_module --with-stream --with-stream_ssl_module --with-http_sub_module --with-http_gzip_static_module --add-module=/nginx_build/module/nginx-module-vts && \
    make && \
    cp ./objs/nginx /nginx_build/stable/nginx/sbin/ && \
    chown -R $UID:$GID /nginx_build/stable/nginx


FROM debian:bullseye-slim

ARG UID=1501 \
    USR=nginx \
    GID=1501 \
    GRP=nginx \
    DIR=/app

ENV NGINX_VERSION=1.20.2 \
    PATH=$PATH:$DIR/nginx/sbin
 
RUN addgroup --system --gid $GID $GRP && \
    adduser --system --disabled-login --ingroup $GRP --no-create-home --home $DIR/$USR --gecos "nginx user" --shell /bin/false --uid $UID $USR && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo 'Asia/Shanghai' > /etc/timezone && \
    apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y ca-certificates gettext-base curl ncat && \
    apt-get remove --purge --auto-remove -y && \
    rm -rf /var/lib/apt/lists/* /etc/apt/sources.list.d/*

COPY docker-entrypoint.sh /
COPY 30-tune-worker-processes.sh /docker-entrypoint.d/
COPY 40-add-sys-app-pod-to-logpath.sh /docker-entrypoint.d/

ENTRYPOINT ["/docker-entrypoint.sh"]

STOPSIGNAL SIGQUIT

USER $USR

WORKDIR $DIR/$USR

COPY --from=builder /nginx_build/stable/ $DIR

CMD ["nginx", "-g", "daemon off;"]

