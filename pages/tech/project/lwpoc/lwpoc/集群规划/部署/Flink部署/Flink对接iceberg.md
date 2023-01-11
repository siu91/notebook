# FLink对接Iceberg文档

## 1. 环境要求 

| 项目     | 软件    | 版本                  |
| -------- | ------- | --------------------- |
| 操作系统 | CentOS  | 7.3 及以上的 7.x 版本 |
| Flink    | FLink   | 1.12.5                |
| Hive     | Hive    | 3.1.0                 |
| iceberg  | iceberg | 0.12                  |

flink已对接好hive，如有疑问参考《Flink解决hive文档》

## 2. 配置Hive连接

2.1 配置conf/sql-client-defaults.yaml

```yaml
catalogs:
   - name: myiceberg
     type: iceberg
     hive-conf-dir: /etc/hive/conf/
     catalog-type: hive
     warehouse: hdfs:///warehouse
```

2.2 拷贝iceberg相关基础库

- iceberg-flink-runtime-0.12.0.jar，下载地址https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-flink-runtime/0.12.0/iceberg-flink-runtime-0.12.0.jar

2.3 测试执行hive处理sql

```
# 启动一个测试集群
./bin/yarn-session.sh -d
# 启动客户端
export HADOOP_CLASSPATH=`hadoop classpath`
./bin/sql-client.sh embedded

# 测试sql查询
select * from `myiceberg`.`iceberg`.`flink_demo` limit 10;
```

