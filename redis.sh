echo "Starting Redis node with username/password authentication..."

CONF_FILE="/tmp/redis.conf"
ACL_FILE="/tmp/users.acl"

# Generate users.acl from environment variables
if [ -z "$REDISCLI_AUTH_USERNAME" ] || [ -z "$REDISCLI_AUTH_PASSWORD" ]; then
    echo "Error: REDISCLI_AUTH_USERNAME and REDISCLI_AUTH_PASSWORD must be set"
    exit 1
fi

cat > $ACL_FILE << EOF
user default on >$REDISCLI_AUTH_PASSWORD ~* &* +@all
user $REDISCLI_AUTH_USERNAME on >$REDISCLI_AUTH_PASSWORD ~* &* +@all
EOF

# generate redis.conf file with ACL support
echo "port 6379
cluster-enabled yes
cluster-config-file nodes.conf
cluster-node-timeout 5000
appendonly yes
loglevel debug
protected-mode no

# ACL Configuration
aclfile $ACL_FILE
requirepass $REDISCLI_AUTH_PASSWORD
" >> $CONF_FILE

# start server
redis-server $CONF_FILE