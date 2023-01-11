#!/usr/bin/env bash
cd queries
for i in {01..99} 
do
query_file=q${i}.sql
echo $query_file
# 把脚本中的database设置为tpcds,schema设置为sf1
QUERY="`sed 's/${database}/tpcds/g;s/${schema}/sf1/g' $query_file`"
# server后面为trino 地址
time trino --server 192.168.5.200:8080 --catalog tpcds --schema sf1 --execute "$QUERY" 1>/dev/null
done
