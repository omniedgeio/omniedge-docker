FROM alpine:3.20

ARG TARGETARCH
ARG VERSION=2.0.0

# Map Docker TARGETARCH to CLI asset naming
# Docker: amd64 -> x64, arm64 -> arm64, arm/v7 -> armv7
RUN apk update && apk add --no-cache bash wget tar

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
    chmod +x /usr/local/bin/omniedge*

# Rename binary to standard name if needed
RUN if [ ! -f /usr/local/bin/omniedge ]; then \
      mv /usr/local/bin/omniedge-cli-* /usr/local/bin/omniedge 2>/dev/null || true; \
    fi

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Default environment variables
ENV OMNIEDGE_MODE=edge
ENV OMNIEDGE_NETWORK_ID=""
ENV OMNIEDGE_SECURITY_KEY=""
ENV OMNIEDGE_SECRET=""
ENV OMNIEDGE_PORT=51820
ENV OMNIEDGE_AS_EXIT_NODE=false
ENV OMNIEDGE_EXIT_NODE=""
ENV OMNIEDGE_VERBOSE=false

EXPOSE 51820/udp

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
