FROM alpine:3.16

ARG TARGETARCH
ARG VERSION=0.2.3

RUN apk update \
  apk add --no-cache wget unzip bash \
  && wget https://github.com/omniedgeio/omniedge/releases/download/v${VERSION}/omniedgecli-${VERSION}-${ARCH}.zip
RUN unzip omniedgecli-${VERSION}-${ARCH}.zip -d /usr/sbin
RUN rm omniedgecli-${VERSION}-${ARCH}.zip

RUN chmod +x /usr/sbin/omniedge
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

COPY entrypoint /usr/sbin/entrypoint
RUN chmod +x /usr/sbin/entrypoint

ENTRYPOINT ["/usr/sbin/entrypoint"]