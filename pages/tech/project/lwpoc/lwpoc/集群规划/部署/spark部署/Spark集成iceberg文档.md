# Spark集成iceberg

### 安装部署

**下载依赖jar包:**

```
 iceberg-spark3-*.jar
 iceberg-spark3-runtime-*.jar
 iceberg-spark3-extensions-*.jar
```

### 配置

#### 手动配置

#### 添加目录

Iceberg 带有[目录](https://iceberg.apache.org/spark-configuration/#catalogs)，使 SQL 命令能够管理表并按名称加载它们。目录是使用 下的属性配置的`spark.sql.catalog.(catalog_name)`。

此命令创建一个以路径命名的目录`hive_prod`，并为 Spark 的内置目录添加对 Iceberg 表的支持：

##### 启动shell样例

```shell
sudo -u hdfs sh bin/spark-shell --conf spark.sql.catalog.hive_prod=org.apache.iceberg.spark.SparkCatalog \
--conf spark.sql.catalog.hive_prod.type=hive \
--conf spark.hadoop.hive.metastore.uris=thrift://dev.bdp.mgmt02:9083 #连接hive连接可移默认配置中(conf/spark-defaults.conf)
```

##### 启动Spark-sql样例

```shell
sudo -u hdfs sh bin/spark-sql --conf spark.sql.catalog.hive_prod=org.apache.iceberg.spark.SparkCatalog \
--conf spark.sql.catalog.hive_prod.type=hive \
--conf spark.hadoop.hive.metastore.uris=thrift://dev.bdp.mgmt02:9083
```

#### 默认配置

配置conf/spark-defaults.conf

```properties
spark.sql.catalog.hive_prod.type=hive
spark.hadoop.hive.metastore.uris=thrift://dev.bdp.mgmt02:9083
spark.sql.catalog.hive_prod=org.apache.iceberg.spark.SparkCatalog

#设置默认的catalog 这里默认catalog为hadoop类型的 hadoop_catalog
#spark.sql.catalog.hadoop_catalog = org.apache.iceberg.spark.SparkCatalog
#spark.sql.catalog.hadoop_catalog.type = hadoop
#spark.sql.catalog.hadoop_catalog.warehouse = hdfs://xxx:8020/user/hive/warehouse/
```

#### 创建表

要在 Spark 中创建您的第一个 Iceberg 表，请使用`spark-sql`shell 或`spark.sql(...)`运行[`CREATE TABLE`](https://iceberg.apache.org/spark-ddl/#create-table)命令：

```sql
-- local is the path-based catalog defined above
CREATE TABLE hive_prod.db.table (id bigint, data string) USING iceberg;
```

要使用 SQL 读取，请在`SELECT`查询中使用 Iceberg 表名称：

```sql
SELECT * FROM hive_prod.db.table;
```

