# OmniEdge Docker

>Latest version: 0.2.4

Run OmniEdge in a container

## Build

```
docker build -t omniedge/omniedge:latest .
```

## Usage

1. By `docker-compose`

```bash
sudo docker-compose up -d
```

2. by `docker run`

```
sudo docker run -d \
  -e OMNIEDGE_SECURITYKEY=OMNIEDGE_SECURITYKEY \
  -e OMNIEDGE_VIRUTALNETWORK_ID="OMNIEDGE_VIRUTALNETWORK_ID" \
  --network host \
  --privileged \
  omniedge/omniedge:latest
```
