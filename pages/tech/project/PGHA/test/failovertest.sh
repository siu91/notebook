#!/bin/bash
#

# pg-afom	  pg-afo monitor

#CURRENT_PATH=$(readlink -f "$(dirname "$0")")


is_secondary=$(sudo su postgres -c "psql -p 5432 -c 'select * from pg_is_in_recovery();'" | head -n 3|tail -n 1)
is_secondary=`echo $is_secondary`

# 如果是主节点
if [[ ${is_secondary} == "f" ]]; then
  echo "10秒后重启系统"
  sleep 10
  /sbin/reboot
fi