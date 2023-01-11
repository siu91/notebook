#!/bin/bash

PATH="$PATH:/sbin"
TRINO_VIP='192.168.5.200'
MASTER_FLAG=$(ip a | grep -c ${TRINO_VIP})

if [ "${MASTER_FLAG}" != 1  ];then
    exit 0
fi

echo $(date '+%Y-%m-%d %H:%M:%S') "${MASTER_FLAG}" "$1" >> /tmp/trino_alive.log
if [ "$1" != "" ];then
    /deploy/trino/trino-server-360/bin/launcher "$1"
    exit $?
else
    count=$(ps -ef| grep -v grep | grep -c TrinoServer)
    if [ "$count" -gt 0 ]; then
       exit 0
    else
        exit 1
    fi
fi