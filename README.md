# OmniEdge Docker

Run OmniEdge VPN in Docker.

## Usage

### Edge Mode (VPN Client)

```bash
docker run -d --name omniedge \
  --privileged --network host \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest \
  edge -n <network-id> -s <security-key>
```

### Nucleus Mode (Signaling Server)

```bash
docker run -d --name omniedge-nucleus \
  --network host \
  omniedge/omniedge:latest \
  nucleus --secret "YourSecretMin16Chars"
```

### Dual Mode (VPN + Signaling)

```bash
docker run -d --name omniedge-dual \
  --privileged --network host \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest \
  dual -n <network-id> -s <security-key> --secret "YourSecretMin16Chars"
```

## Options

| Option | Short | Description |
|--------|-------|-------------|
| `--network-id` | `-n` | Network ID (edge/dual) |
| `--security-key` | `-s` | Security key (edge/dual) |
| `--secret` | | Cluster secret (nucleus/dual, min 16 chars) |
| `--port` | `-p` | UDP port (default: 51820) |
| `--as-exit-node` | `-x` | Act as exit node |
| `--exit-node` | `-e` | Route through exit node IP |
| `--verbose` | `-v` | Debug logging |

## Docker Compose

```bash
# Edge mode
OMNIEDGE_NETWORK_ID=<id> OMNIEDGE_SECURITY_KEY=<key> \
  docker compose up omniedge-edge -d

# Nucleus mode
OMNIEDGE_SECRET=YourSecretMin16Chars \
  docker compose up omniedge-nucleus -d

# Dual mode
OMNIEDGE_NETWORK_ID=<id> OMNIEDGE_SECURITY_KEY=<key> OMNIEDGE_SECRET=<secret> \
  docker compose up omniedge-dual -d
```

## Exit Node

```bash
# Run as exit node
docker run -d --name omniedge \
  --privileged --network host \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest \
  edge -n <network-id> -s <security-key> --as-exit-node

# Use exit node
docker run -d --name omniedge \
  --privileged --network host \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest \
  edge -n <network-id> -s <security-key> --exit-node 10.0.0.1
```

## Commands

```bash
# View logs
docker logs omniedge

# Check status
docker exec omniedge omniedge status

# Stop
docker stop omniedge
```

## Build

```bash
docker build -t omniedge/omniedge:latest .

# Multi-arch
docker buildx build --platform linux/amd64,linux/arm64 \
  -t omniedge/omniedge:latest --push .
```

## Architectures

- `linux/amd64`
- `linux/arm64`
