#!/bin/bash

# Load environment variables from .env
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

echo "Starting Redis Cluster with username/password authentication..."
docker-compose up -d

echo "Waiting for cluster to initialize..."
sleep 8

echo "Redis Cluster is starting up!"
echo ""
echo "Services:"
echo "  - Redis Nodes (6): ports 7001-7006 (HAProxy: 9001-9006)"
echo "  - HAProxy Stats: http://localhost:8404/stats"
echo "  - Redis Insight: http://localhost:8001"
echo ""
echo "Cluster details:"
docker-compose exec -T -e REDISCLI_AUTH="$REDISCLI_AUTH_PASSWORD" redis-node-1 redis-cli cluster info | head -20
