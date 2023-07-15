FROM debian:12.0-slim

RUN mkdir -p /build
COPY sniproxy/ /build
COPY sources.list ./etc/apt/

WORKDIR /build
RUN apt-get update && apt-get -y install autotools-dev cdbs debhelper dh-autoreconf dpkg-dev gettext libev-dev libpcre3-dev libudns-dev pkg-config fakeroot devscripts
RUN ./autogen.sh && \
    ./configure && \
    make && \
    make install && ls -la

FROM debian:12.0-slim
RUN mkdir /etc/sniproxy
COPY --from=0 /usr/local/sbin/sniproxy /bin
COPY sniproxy.conf /etc/sniproxy
COPY sources.list ./etc/apt/
RUN apt-get update && apt-get install -y libev4 libpcre3 libudns0
CMD ["sniproxy", "-c", "/etc/sniproxy/sniproxy.conf", "-f"]