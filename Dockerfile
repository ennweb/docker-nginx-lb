FROM ubuntu:14.04.3

RUN \
  apt-get update && \
  apt-get install -y wget gcc make patch libpcre3-dev libssl-dev zlib1g-dev libgeoip-dev apache2-utils && \
  wget https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64 -O /usr/bin/confd && \
  chmod +x /usr/bin/confd && \
  wget http://nginx.org/download/nginx-1.9.5.tar.gz && \
  tar -xzf nginx-1.9.5.tar.gz && \
  cd nginx-1.9.5 && \
  wget https://github.com/yaoweibin/nginx_upstream_check_module/archive/master.tar.gz -O patch.tgz && \
  tar -xzf patch.tgz && \
  patch -p0 < nginx_upstream_check_module-master/check_1.9.2+.patch && \
  ./configure \
    --with-cc-opt='-g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -D_FORTIFY_SOURCE=2' \
    --with-ld-opt='-Wl,-Bsymbolic-functions -Wl,-z,relro' \
    --add-module=nginx_upstream_check_module-master \
    --prefix=/usr/share/nginx \
    --sbin-path=/usr/sbin/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --lock-path=/var/run/nginx.lock \
    --pid-path=/run/nginx.pid \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --with-pcre-jit \
    --with-ipv6 \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_geoip_module \
    --with-http_gzip_static_module \
    --with-http_sub_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-http_v2_module \
    --with-file-aio \
    --with-http_auth_request_module \
    --with-stream \
    --with-stream_ssl_module \
    --without-http_scgi_module \
    --without-http_uwsgi_module \
    --without-http_fastcgi_module && \
  make && make install && cd / && rm -rf /nginx* && \
  apt-get remove -y wget gcc make patch libpcre3-dev libssl-dev zlib1g-dev libpcrecpp0 libssl-doc && \
  apt-get autoremove -y && apt-get clean && apt-get autoclean && \
  rm -rf /var/lib/apt/lists/* && \
  ln -sf /dev/stdout /var/log/nginx/access.log && \
  ln -sf /dev/stderr /var/log/nginx/error.log && \
  rm -rf /etc/nginx/nginx.conf && \
  mkdir -p /etc/nginx/conf.d && \
  mkdir -p /etc/nginx/keys

COPY confd /etc/confd
COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx-lb /usr/bin/nginx-lb

EXPOSE 80 443

ENTRYPOINT ["nginx-lb"]
