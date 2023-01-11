#!/bin/bash

PATH="$PATH:/sbin"
flock -xn /tmp/pgafom-status -c 'sh -x /etc/keepalived/monitor.sh >> /etc/keepalived/.log'
exit 0

