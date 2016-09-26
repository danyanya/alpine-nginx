FROM alpine:3.2

MAINTAINER Daniil Sliusar <dsliusar@wimarksystems.com>

ENV NGINX_VERSION nginx-1.9.7

RUN apk --update add openssl-dev pcre-dev zlib-dev wget build-base bash \
    && wget http://nginx.org/download/${NGINX_VERSION}.tar.gz \
    && tar -zxvf ${NGINX_VERSION}.tar.gz \
    && cd ${NGINX_VERSION} \
    && ./configure \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_gzip_static_module \
        --prefix=/etc/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
        --sbin-path=/usr/local/sbin/nginx \
    && make \
    && make install \
    && cd / \
    && rm -rf ${NGINX_VERSION} && rm ${NGINX_VERSION}.tar.gz \
    && rm -rf /etc/nginx/nginx.conf \
    && apk del make wget build-base \
    && rm -rf /tmp/* /root/.npm /root/.node-gyp /var/cache/apk/*

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/log/nginx"]

WORKDIR /etc/nginx

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
