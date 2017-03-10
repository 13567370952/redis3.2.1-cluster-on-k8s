#!/bin/bash

if [ "${REDIS_PASS}" == "**Random**" ]; then
    unset REDIS_PASS
fi

# Set initial configuration
if [ ! -f /.redis_configured ]; then
    touch /etc/redis/redis_default.conf

    echo "bind 0.0.0.0" >> /etc/redis/redis_default.conf
echo "port 6379" >> /etc/redis/redis_default.conf
echo "cluster-enabled yes" >> /etc/redis/redis_default.conf
echo "cluster-config-file /redis-data/nodes.conf" >> /etc/redis/redis_default.conf
echo "cluster-node-timeout 5000" >> /etc/redis/redis_default.conf
echo "appendonly yes" >> /etc/redis/redis_default.conf
echo "dir /redis-data" >> /etc/redis/redis_default.conf
    if [ "${REDIS_PASS}" != "**None**" ]; then
        PASS=${REDIS_PASS:-$(pwgen -s 32 1)}
        _word=$( [ ${REDIS_PASS} ] && echo "preset" || echo "random" )
        echo "=> Securing redis with a ${_word} password"
        echo "requirepass $PASS" >> /etc/redis/redis_default.conf
        echo "masterauth $PASS" >> /etc/redis/redis_default.conf
        echo "=> Done!"
        echo "========================================================================"
        echo "You can now connect to this Redis server using:"
        echo ""
        echo "    redis-cli -a $PASS -h <host> -p <port>"
        echo ""
        echo "Please remember to change the above password as soon as possible!"
        echo "========================================================================"
    fi

    touch /.redis_configured
fi



exec /redis/src/redis-server /etc/redis/redis_default.conf
