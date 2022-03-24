# trino配置Catalog

## Trino集成TiDB

在trino配置目录中添加etc/catalog/tidb.properties，内容如下:

```properties
connector.name=mysql
connection-url=jdbc:mysql://192.168.6.200:4000
connection-user=[user]
connection-password=[password]
```

## Trino集成PG

在trino配置目录中添加etc/catalog/postgresql.properties，内容如下:

```properties
connector.name=postgresql
connection-url=jdbc:postgresql://192.168.6.146:5432
connection-user=[user]
connection-password=[password]
```

## Trino集成Hive

在trino配置目录中添加etc/catalog/hive.properties，内容如下:

```properties
connector.name=hive
hive.metastore.uri=thrift://dev.bdp.mgmt02:9083
hive.config.resources=/etc/hadoop/conf/core-site.xml,/etc/hadoop/conf/hdfs-site.xml
```

## Trino集成Iceberg

在trino配置目录中添加etc/catalog/iceberg.properties，内容如下:

```properties
connector.name=iceberg
hive.metastore.uri=thrift://dev.bdp.mgmt02:9083
hive.config.resources=/etc/hadoop/conf/core-site.xml,/etc/hadoop/conf/hdfs-site.xml
```

