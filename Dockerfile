# Dockerfile - alpine
# https://github.com/openresty/docker-openresty

ARG RESTY_IMAGE_BASE="alpine"
ARG RESTY_IMAGE_TAG="3.11"

FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}

LABEL maintainer="Wuluoyong"

# Docker Build Arguments
ARG RESTY_IMAGE_BASE="alpine"
ARG RESTY_IMAGE_TAG="3.11"

ADD jxwaf /tmp/jxwaf

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        curl \
        make \
        perl-dev \
        readline-dev \
        zlib-dev \
        g++ \
        gcc \
        python3-dev libffi-dev openssl-dev \
        pcre-dev \
        lua-dev \
        cmake \
        automake \
    && apk add --no-cache \
        zlib \
        openssl \
        lua \
        pcre \
        libgcc \
        libuuid \
    && apk add --no-cache --update python3 \
    && pip3 install --upgrade pip \
    && pip3 install requests \
    && cd /tmp/jxwaf \
    && tar zxvf openresty-1.15.8.3.tar.gz \
    && tar zxvf libmaxminddb-1.3.2.tar.gz \
    && tar zxvf aliyun-log-c-sdk-lite.tar.gz \
    && tar zxvf curl-7.64.1.tar.gz \
    && cd curl-7.64.1 \
    && make \
    && make install \
    && cd ../openresty-1.15.8.3 \
    && ./configure --prefix=/opt/jxwaf --with-http_v2_module \
    && make \
    && make install \
    && mv /opt/jxwaf/nginx/conf/nginx.conf  /opt/jxwaf/nginx/conf/nginx.conf.bak \
    && cp ../conf/nginx.conf /opt/jxwaf/nginx/conf/ \
    && cp -r ../tools /opt/jxwaf/tools \
    && cp ../conf/full_chain.pem /opt/jxwaf/nginx/conf/ \
    && cp ../conf/private.key /opt/jxwaf/nginx/conf/ \
    && mkdir /opt/jxwaf/nginx/conf/jxwaf \
    && cp ../conf/jxwaf_config.json /opt/jxwaf/nginx/conf/jxwaf/ \
    && cp ../conf/GeoLite2-Country.mmdb /opt/jxwaf/nginx/conf/jxwaf/ \
    && cp -r ../lib/resty/jxwaf  /opt/jxwaf/lualib/resty/ \
    && cd ../libmaxminddb-1.3.2 \
    && ./configure \
    && make \
    && cp src/.libs/libmaxminddb.so.0.0.7 /opt/jxwaf/lualib/libmaxminddb.so \
    && cd ../aliyun-log-c-sdk-lite \
    && cmake . \
    && make \
    && cp build/lib/liblog_c_sdk.so.2.0.0 /opt/jxwaf/lualib/liblog_c_sdk.so \
    && apk del .build-deps \
    && cd /tmp \
    && rm -rf jxwaf

# Add additional binaries into PATH for convenience
ENV PATH=$PATH:/opt/jxwaf/luajit/bin:/opt/jxwaf/nginx/sbin:/opt/jxwaf/bin


ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
ADD ca-bundle.crt /etc/pki/tls/certs/ca-bundle.crt
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && chmod 644 /etc/pki/tls/certs/ca-bundle.crt
ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 80 443
CMD ["/opt/jxwaf/nginx/sbin/nginx","-g","daemon off;"]

STOPSIGNAL SIGQUIT