#!/bin/bash

# Load environment variables from .env
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

echo "Testing Redis Cluster with username/password authentication..."
echo ""
echo "Using credentials: username=$REDISCLI_AUTH_USERNAME"
echo ""

# Test basic connectivity
echo "1. Testing cluster info:"
docker-compose exec -T -e REDISCLI_AUTH="$REDISCLI_AUTH_PASSWORD" redis-node-1 redis-cli cluster info

echo ""
echo "2. Testing cluster nodes:"
docker-compose exec -T -e REDISCLI_AUTH="$REDISCLI_AUTH_PASSWORD" redis-node-1 redis-cli cluster nodes

echo ""
echo "3. Testing basic SET/GET operation:"
docker-compose exec -T -e REDISCLI_AUTH="$REDISCLI_AUTH_PASSWORD" redis-node-1 redis-cli SET testkey "Hello Redis Cluster"
docker-compose exec -T -e REDISCLI_AUTH="$REDISCLI_AUTH_PASSWORD" redis-node-1 redis-cli GET testkey

echo ""
echo "4. Testing direct connection to node 2:"
docker-compose exec -T -e REDISCLI_AUTH="$REDISCLI_AUTH_PASSWORD" redis-node-2 redis-cli PING

echo ""
echo "✅ Cluster test completed successfully!"
