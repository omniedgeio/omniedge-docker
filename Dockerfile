FROM alpine:3.16

ARG TARGETARCH
ARG VERSION=2.0.0

# Map Docker TARGETARCH to CLI asset naming
# Docker uses: amd64, arm64, arm
# CLI uses: amd64, arm64, arm
RUN apk update && apk add --no-cache bash wget unzip

RUN wget https://github.com/omniedgeio/omniedge/releases/download/v${VERSION}/omniedge-v${VERSION}-${TARGETARCH}.zip \
    && unzip omniedge-v${VERSION}-${TARGETARCH}.zip -d /usr/sbin \
    && rm omniedge-v${VERSION}-${TARGETARCH}.zip

RUN chmod +x /usr/sbin/omniedge

# Create symlink for libc on x86_64
RUN if [ "$(uname -m)" = "x86_64" ]; then \
      mkdir -p /lib64 && ln -sf /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2; \
    fi

COPY entrypoint /usr/sbin/entrypoint
RUN chmod +x /usr/sbin/entrypoint

ENTRYPOINT ["/usr/sbin/entrypoint"]
