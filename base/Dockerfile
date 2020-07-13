# Dockerfile - alpine
# https://github.com/openresty/docker-openresty

ARG RESTY_IMAGE_BASE="alpine"
ARG RESTY_IMAGE_TAG="3.11"

FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}

LABEL maintainer="Wuluoyong"

# Docker Build Arguments
ARG RESTY_IMAGE_BASE="alpine"
ARG RESTY_IMAGE_TAG="3.11"
ARG RESTY_VERSION="1.15.8.3"
ARG RESTY_OPENSSL_VERSION="1.1.1g"
ARG RESTY_OPENSSL_PATCH_VERSION="1.1.1f"
ARG RESTY_OPENSSL_URL_BASE="https://www.openssl.org/source"
ARG RESTY_PCRE_VERSION="8.44"
ARG RESTY_J="1"
ARG RESTY_CONFIG_OPTIONS="\
    --with-http_v2_module \
"
ARG RESTY_CONFIG_OPTIONS_MORE=""
ARG RESTY_LUAJIT_OPTIONS="--with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT'"

ARG RESTY_ADD_PACKAGE_BUILDDEPS=""
ARG RESTY_ADD_PACKAGE_RUNDEPS=""
ARG RESTY_EVAL_PRE_CONFIGURE=""
ARG RESTY_EVAL_POST_MAKE=""

# These are not intended to be user-specified
ARG _RESTY_CONFIG_DEPS="--with-pcre \
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I/opt/jxwaf/pcre/include -I/opt/jxwaf/openssl/include' \
    --with-ld-opt='-L/opt/jxwaf/pcre/lib -L/opt/jxwaf/openssl/lib -Wl,-rpath,/opt/jxwaf/pcre/lib:/opt/jxwaf/openssl/lib' \
    "

LABEL resty_image_base="${RESTY_IMAGE_BASE}"
LABEL resty_image_tag="${RESTY_IMAGE_TAG}"
LABEL resty_version="${RESTY_VERSION}"
LABEL resty_openssl_version="${RESTY_OPENSSL_VERSION}"
LABEL resty_openssl_patch_version="${RESTY_OPENSSL_PATCH_VERSION}"
LABEL resty_openssl_url_base="${RESTY_OPENSSL_URL_BASE}"
LABEL resty_pcre_version="${RESTY_PCRE_VERSION}"
LABEL resty_config_options="${RESTY_CONFIG_OPTIONS}"
LABEL resty_config_options_more="${RESTY_CONFIG_OPTIONS_MORE}"
LABEL resty_config_deps="${_RESTY_CONFIG_DEPS}"
LABEL resty_add_package_builddeps="${RESTY_ADD_PACKAGE_BUILDDEPS}"
LABEL resty_add_package_rundeps="${RESTY_ADD_PACKAGE_RUNDEPS}"
LABEL resty_eval_pre_configure="${RESTY_EVAL_PRE_CONFIGURE}"
LABEL resty_eval_post_make="${RESTY_EVAL_POST_MAKE}"

ADD jxwaf /tmp/jxwaf

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
    && apk update \
    && apk add --no-cache --virtual .build-deps \
        build-base \
        coreutils \
        curl \
        gd-dev \
        geoip-dev \
        libxslt-dev \
        linux-headers \
        make \
        perl-dev \
        readline-dev \
        zlib-dev \
        g++ \
        python3-dev libffi-dev openssl-dev \
        ${RESTY_ADD_PACKAGE_BUILDDEPS} \
    && apk add --no-cache \
        gd \
        geoip \
        libgcc \
        libxslt \
        zlib \
        ${RESTY_ADD_PACKAGE_RUNDEPS} \
    && apk add --no-cache --update python3 \
    && pip3 install --upgrade pip \
    && pip3 install requests \
    && cd /tmp \
    && if [ -n "${RESTY_EVAL_PRE_CONFIGURE}" ]; then eval $(echo ${RESTY_EVAL_PRE_CONFIGURE}); fi \
    && cd /tmp \
    && curl -fSL "${RESTY_OPENSSL_URL_BASE}/openssl-${RESTY_OPENSSL_VERSION}.tar.gz" -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && cd openssl-${RESTY_OPENSSL_VERSION} \
    && if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.1" ] ; then \
        echo 'patching OpenSSL 1.1.1 for OpenResty' \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-${RESTY_OPENSSL_PATCH_VERSION}-sess_set_get_cb_yield.patch | patch -p1 ; \
    fi \
    && if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.0" ] ; then \
        echo 'patching OpenSSL 1.1.0 for OpenResty' \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/ed328977028c3ec3033bc25873ee360056e247cd/patches/openssl-1.1.0j-parallel_build_fix.patch | patch -p1 \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-${RESTY_OPENSSL_PATCH_VERSION}-sess_set_get_cb_yield.patch | patch -p1 ; \
    fi \
    && ./config \
      no-threads shared zlib -g \
      enable-ssl3 enable-ssl3-method \
      --prefix=/opt/jxwaf/openssl \
      --libdir=lib \
      -Wl,-rpath,/opt/jxwaf/openssl/lib \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install_sw \
    && cd /tmp \
    && curl -fSL https://ftp.pcre.org/pub/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && cd /tmp/pcre-${RESTY_PCRE_VERSION} \
    && ./configure \
        --prefix=/opt/jxwaf/pcre \
        --disable-cpp \
        --enable-jit \
        --enable-utf \
        --enable-unicode-properties \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && cd /tmp \
    && if [ -n "${RESTY_EVAL_POST_MAKE}" ]; then eval $(echo ${RESTY_EVAL_POST_MAKE}); fi \
    && rm -rf \
       openssl-${RESTY_OPENSSL_VERSION}.tar.gz openssl-${RESTY_OPENSSL_VERSION} \
       pcre-${RESTY_PCRE_VERSION}.tar.gz pcre-${RESTY_PCRE_VERSION} \
    && cd /tmp/jxwaf \
    && tar zxvf openresty-1.15.8.3.tar.gz \
    && tar zxvf libmaxminddb-1.3.2.tar.gz \
    && tar zxvf aliyun-log-c-sdk-lite.tar.gz \
    && tar zxvf curl-7.64.1.tar.gz \
    && cd curl-7.64.1 \
    && make \
    && make install \
    && cd ../openresty-1.15.8.3 \
    && eval ./configure --prefix=/opt/jxwaf -j${RESTY_J} ${_RESTY_CONFIG_DEPS} ${RESTY_CONFIG_OPTIONS} ${RESTY_CONFIG_OPTIONS_MORE} ${RESTY_LUAJIT_OPTIONS} \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && mv /opt/jxwaf/nginx/conf/nginx.conf  /opt/jxwaf/nginx/conf/nginx.conf.bak \
    && cp ../conf/nginx.conf /opt/jxwaf/nginx/conf/ \
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
    #&& cd ../aliyun-log-c-sdk-lite \
    #&& cmake . \
    #&& make \
    #&& cp build/lib/liblog_c_sdk.so.2.0.0 /opt/jxwaf/lualib/liblog_c_sdk.so \
    && apk del .build-deps \
    && cd /tmp \
    && rm -rf jxwaf

# Add additional binaries into PATH for convenience
ENV PATH=$PATH:/opt/jxwaf/luajit/bin:/opt/jxwaf/nginx/sbin:/opt/jxwaf/bin


ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
EXPOSE 80 443
CMD ["/opt/jxwaf/nginx/sbin/nginx","-g","daemon off;"]

STOPSIGNAL SIGQUIT