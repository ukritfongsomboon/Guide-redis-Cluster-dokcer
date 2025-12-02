# Redis Cluster Setup

Redis Cluster with username and password authentication using HAProxy load balancer

## Requirements

- Docker
- Docker Compose
- Redis CLI (for manual testing)

## Quick Start

### 1. Configure Environment Variables

Edit `.env` file:

```bash
REDISCLI_AUTH_USERNAME=admin
REDISCLI_AUTH_PASSWORD=admin
```

Use your desired username and password.

### 2. Start Cluster

```bash
./start-cluster.sh
```

This script will:
- Create and start 6 Redis nodes (3 masters, 3 slaves)
- Configure HAProxy load balancer
- Initialize the cluster
- Start Redis Insight

### 3. Test Cluster

```bash
./test-cluster.sh
```

This script will:
- Check cluster info
- Display cluster nodes
- Test SET/GET operations
- Test direct node connection

### 4. Stop Cluster

```bash
./stop-cluster.sh
```

## File Structure

| File | Description |
|------|-------------|
| `.env` | Configuration file for username and password (WARNING: Do not commit) |
| `redis.sh` | Startup script for each Redis node - generates config and ACL from env variables |
| `docker-compose.yaml` | Docker Compose configuration - defines 6 Redis nodes, HAProxy, and Redis Insight |
| `start-cluster.sh` | Script to start cluster and initialize it |
| `stop-cluster.sh` | Script to stop cluster and remove volumes |
| `test-cluster.sh` | Script to test cluster functionality |
| `server.crt` | SSL Certificate (not used in current setup) |
| `server.key` | SSL Private Key (not used in current setup) |
| `dhparams.pem` | DH Parameters (not used in current setup) |
| `haproxy/` | HAProxy configuration directory |
| `.gitignore` | Git ignore rules (protects .env from being committed) |
| `.env.example` | Example environment variables template |

## Connecting to Redis Insight

### Step 1: Open Redis Insight

Go to **http://localhost:8001**

### Step 2: Add Redis Database

1. Click **+ Add Redis Database**
2. Select **Connect to a Redis Stack database** or **Connect to a Redis database**
3. Fill in the connection details:

**Option 1: Direct Connection to Node**
```
Host: redis-node-1
Port: 6379
Username: admin
Password: admin
```

**Option 2: Connection via HAProxy (Recommended)**
```
Host: redis-proxy
Port: 6379
Username: admin
Password: admin
```

### Step 3: Test Connection

- Click **Test Connection** to verify
- Click **Add Redis Database** to save

## Architecture

```
┌─────────────────────────────────────────────┐
│         Redis Insight (Port 8001)           │
│              Web Management UI              │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│  HAProxy Load Balancer (Port 6379, 7001-7006)
├──────────────────┬──────────────────────────┤
│     Master 1     │   Master 2      Master 3 │
│     (6379)       │   (6379)        (6379)   │
│        │         │      │             │     │
│     Slave 1      │   Slave 2      Slave 3   │
└─────────────────────────────────────────────┘
```

## Authentication

### Default User
- Username: `default`
- Password: Value from `REDISCLI_AUTH_PASSWORD` in `.env`

### Custom User
- Username: Value from `REDISCLI_AUTH_USERNAME` in `.env`
- Password: Value from `REDISCLI_AUTH_PASSWORD` in `.env`

Both users can be used interchangeably as both are configured in the ACL file.

## Usage Examples

### Get Cluster Info
```bash
export REDISCLI_AUTH='admin'
redis-cli -h redis-proxy -p 6379 cluster info
```

### SET/GET Operations
```bash
export REDISCLI_AUTH='admin'
redis-cli -h redis-proxy -p 6379 SET mykey "Hello Redis"
redis-cli -h redis-proxy -p 6379 GET mykey
```

### Monitor Commands
```bash
export REDISCLI_AUTH='admin'
redis-cli -h redis-proxy -p 6379 MONITOR
```

## Troubleshooting

### Error: "NOAUTH Authentication required"
- Check `.env` has `REDISCLI_AUTH_USERNAME` and `REDISCLI_AUTH_PASSWORD`
- Restart cluster: `./stop-cluster.sh && ./start-cluster.sh`

### Error: "Connection refused"
- Check containers are running: `docker-compose ps`
- Check logs: `docker-compose logs redis-node-1`

### Error: "cluster_state:fail"
- Cluster may still be initializing, wait 10 seconds
- Try `./test-cluster.sh` again

### Redis Insight cannot connect
- Check port 8001 is exposed: `docker-compose ps redis-insight`
- Try using `127.0.0.1` instead of `localhost`

## Important Notes

WARNING: Do not commit `.env` file - it contains credentials
- Ensure `.gitignore` includes `.env`

WARNING: Use strong passwords in production
- Do not use `admin` in production environments

WARNING: Required open ports
- Ensure these ports are available:
  - 6379 (Redis)
  - 7001-7006 (HAProxy)
  - 8001 (Redis Insight)
  - 8404 (HAProxy Stats)

## Services and Ports

| Service | Port | Purpose |
|---------|------|---------|
| Redis Nodes 1-6 | 6379 | Redis Cluster Nodes |
| HAProxy | 7001-7006 | Load Balancer (forwarded from 9001-9006) |
| HAProxy Stats | 8404 | HAProxy Statistics Dashboard |
| Redis Insight | 8001 | Web-based Redis Management UI |

## Useful Links

- Redis Cluster Documentation: https://redis.io/docs/management/clustering/
- Redis CLI: https://redis.io/docs/connect/cli/
- HAProxy: http://www.haproxy.org/
- Redis Insight: https://redis.com/redis-enterprise/redis-insight/

## License

MIT

---

Created: 2025-12-02
Version: 1.0.0
