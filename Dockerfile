FROM alpine:3.20

ARG TARGETARCH
ARG VERSION=2.7.0-pre

RUN apk update && apk add --no-cache wget tar

# Download and install omniedge CLI
RUN case "${TARGETARCH}" in \
      amd64) CLI_ARCH="x64" ;; \
      arm64) CLI_ARCH="arm64" ;; \
      arm)   CLI_ARCH="armv7" ;; \
      *)     CLI_ARCH="${TARGETARCH}" ;; \
    esac && \
    wget -q "https://github.com/omniedgeio/omniedge/releases/download/v${VERSION}/omniedge-cli-${VERSION}-linux-${CLI_ARCH}.tar.gz" -O /tmp/omniedge.tar.gz && \
    tar -xzf /tmp/omniedge.tar.gz -C /usr/local/bin && \
    rm /tmp/omniedge.tar.gz && \
    chmod +x /usr/local/bin/omniedge* && \
    if [ ! -f /usr/local/bin/omniedge ]; then \
      mv /usr/local/bin/omniedge-cli-* /usr/local/bin/omniedge 2>/dev/null || true; \
    fi

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 51820/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD pgrep -x omniedge > /dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
