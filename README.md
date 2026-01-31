# OmniEdge Docker

Run OmniEdge VPN in a Docker container.

## Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# 1. Clone and configure
git clone https://github.com/omniedgeio/omniedge-docker.git
cd omniedge-docker
cp .env.example .env

# 2. Edit .env with your credentials
#    OMNIEDGE_NETWORK_ID=your-network-id
#    OMNIEDGE_SECURITY_KEY=your-security-key

# 3. Start
docker compose up -d

# Check status
docker compose logs -f
```

### Option 2: Docker Run

```bash
# Edge mode (VPN client)
docker run -d --name omniedge \
  --privileged --network host \
  -e OMNIEDGE_NETWORK_ID=<your-network-id> \
  -e OMNIEDGE_SECURITY_KEY=<your-security-key> \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest

# Or with CLI flags
docker run -d --name omniedge \
  --privileged --network host \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest \
  start -n <network-id> -s <security-key>
```

## Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `edge` | VPN client (default) | Connect to your network |
| `nucleus` | Signaling server | Self-host relay server |
| `dual` | VPN + signaling | Edge node that also relays |

### Edge Mode (Default)

```bash
docker run -d --name omniedge \
  --privileged --network host \
  -e OMNIEDGE_NETWORK_ID=<id> \
  -e OMNIEDGE_SECURITY_KEY=<key> \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest
```

### Nucleus Mode

```bash
docker run -d --name omniedge-nucleus \
  --network host \
  -e OMNIEDGE_MODE=nucleus \
  -e OMNIEDGE_SECRET=YourSecretMin16Chars \
  omniedge/omniedge:latest
```

### Dual Mode

```bash
docker run -d --name omniedge-dual \
  --privileged --network host \
  -e OMNIEDGE_MODE=dual \
  -e OMNIEDGE_NETWORK_ID=<id> \
  -e OMNIEDGE_SECURITY_KEY=<key> \
  -e OMNIEDGE_SECRET=YourSecretMin16Chars \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest
```

## Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `OMNIEDGE_MODE` | No | `edge` | Mode: `edge`, `nucleus`, `dual` |
| `OMNIEDGE_NETWORK_ID` | edge/dual | - | Network ID from dashboard |
| `OMNIEDGE_SECURITY_KEY` | edge/dual | - | Security key from dashboard |
| `OMNIEDGE_SECRET` | nucleus/dual | - | Cluster secret (min 16 chars) |
| `OMNIEDGE_PORT` | No | `51820` | UDP port for nucleus |
| `OMNIEDGE_AS_EXIT_NODE` | No | `false` | Act as exit node |
| `OMNIEDGE_EXIT_NODE` | No | - | Use specific exit node IP |
| `OMNIEDGE_VERBOSE` | No | `false` | Enable debug logging |

## CLI Flags

You can also pass flags directly:

```bash
docker run omniedge/omniedge start --help
```

| Flag | Short | Description |
|------|-------|-------------|
| `--mode` | `-m` | Operating mode |
| `--network-id` | `-n` | Network ID |
| `--security-key` | `-s` | Security key |
| `--secret` | | Cluster secret |
| `--port` | `-p` | Nucleus port |
| `--as-exit-node` | `-x` | Act as exit node |
| `--exit-node` | `-e` | Use exit node |
| `--verbose` | `-v` | Debug logging |

## Exit Node

### Advertise as Exit Node

```bash
docker run -d --name omniedge \
  --privileged --network host \
  -e OMNIEDGE_NETWORK_ID=<id> \
  -e OMNIEDGE_SECURITY_KEY=<key> \
  -e OMNIEDGE_AS_EXIT_NODE=true \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest
```

### Route Through Exit Node

```bash
docker run -d --name omniedge \
  --privileged --network host \
  -e OMNIEDGE_NETWORK_ID=<id> \
  -e OMNIEDGE_SECURITY_KEY=<key> \
  -e OMNIEDGE_EXIT_NODE=10.0.0.1 \
  -v /dev/net/tun:/dev/net/tun \
  omniedge/omniedge:latest
```

## Build

```bash
# Local build
docker build -t omniedge/omniedge:latest .

# With specific version
docker build --build-arg VERSION=2.0.0 -t omniedge/omniedge:2.0.0 .

# Multi-arch
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t omniedge/omniedge:latest --push .
```

## Architectures

- `linux/amd64` - x86_64 servers
- `linux/arm64` - Raspberry Pi 4/5, AWS Graviton
- `linux/arm/v7` - Raspberry Pi 3

## Troubleshooting

```bash
# View logs
docker logs omniedge

# Check status
docker exec omniedge omniedge status

# Interactive shell
docker exec -it omniedge sh
```

## License

Apache-2.0 OR MIT
