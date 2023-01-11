# FLink对接Hive文档

## 1. 环境要求 

| 项目     | 软件   | 版本                  |
| -------- | ------ | --------------------- |
| 操作系统 | CentOS | 7.3 及以上的 7.x 版本 |
| Flink    | FLink  | 1.12.5                |
| Hive     | Hive   | 3.1.0                 |
|          |        |                       |



## 2. 配置Hive连接

2.1 配置conf/sql-client-defaults.yaml

```yaml
catalogs:
   - name: myhive
     type: hive
     hive-conf-dir: /etc/hive/conf/
```

2.2 拷贝hive相关基础库

- flink-sql-connector-hive-3.1.2_2.11-1.12-SNAPSHOT.jar (需要重新编译获得，编译方法参考附录)

运行环境中拷贝一下hadoop库：

- hadoop-common-3.1.1.3.1.5.0-152.jar
- hadoop-mapreduce-client-common-3.1.1.3.1.5.0-152.jar      
- hadoop-mapreduce-client-core-3.1.1.3.1.5.0-152.jar
- hadoop-mapreduce-client-jobclient-3.1.1.3.1.5.0-152.jar

2.3 测试执行hive处理sql

```
# 启动一个测试集群
./bin/yarn-session.sh -d
# 启动客户端
export HADOOP_CLASSPATH=`hadoop classpath`
./bin/sql-client.sh embedded

# 测试sql查询
select * from `myhive`.`tpcds_text_10`.`customer` limit 10;
```

## 3. 过程中问题记录

3.1 未指定添加hive响应的connector,报错如下

```shell
Exception in thread "main" org.apache.flink.table.client.SqlClientException: Unexpected exception. This is a bug. Please consider filing an issue.
        at org.apache.flink.table.client.SqlClient.main(SqlClient.java:215)
Caused by: org.apache.flink.table.client.gateway.SqlExecutionException: Could not create execution context.
        at org.apache.flink.table.client.gateway.local.ExecutionContext$Builder.build(ExecutionContext.java:972)
        at org.apache.flink.table.client.gateway.local.LocalExecutor.openSession(LocalExecutor.java:225)
        at org.apache.flink.table.client.SqlClient.start(SqlClient.java:108)
        at org.apache.flink.table.client.SqlClient.main(SqlClient.java:201)
Caused by: org.apache.flink.table.api.NoMatchingTableFactoryException: Could not find a suitable table factory for 'org.apache.flink.table.factories.CatalogFactory' in
the classpath.

Reason: Required context properties mismatch.
```

解决：参考[Apache Flink 1.12 Documentation: Hive](https://ci.apache.org/projects/flink/flink-docs-release-1.12/dev/table/connectors/hive/)文档，添加hive相关jar包。

3.2 与hive的guava版本冲突

```
Caused by: java.lang.NoSuchMethodError: com.google.common.base.Preconditions.checkArgument(ZLjava/lang/String;Ljava/lang/Object;)V
        at org.apache.hadoop.conf.Configuration.set(Configuration.java:1358)
        at org.apache.hadoop.conf.Configuration.set(Configuration.java:1339)
        at org.apache.hadoop.mapred.JobConf.setJar(JobConf.java:518)
        at org.apache.hadoop.mapred.JobConf.setJarByClass(JobConf.java:536)
        at org.apache.hadoop.mapred.JobConf.<init>(JobConf.java:430)
        at org.apache.hadoop.hive.conf.HiveConf.initialize(HiveConf.java:5141)
        at org.apache.hadoop.hive.conf.HiveConf.<init>(HiveConf.java:5109)
        at org.apache.flink.table.catalog.hive.HiveCatalog.createHiveConf(HiveCatalog.java:230)
        at org.apache.flink.table.catalog.hive.HiveCatalog.<init>(HiveCatalog.java:169)
        at org.apache.flink.table.catalog.hive.factories.HiveCatalogFactory.createCatalog(HiveCatalogFactory.java:97)
        at org.apache.flink.table.client.gateway.local.ExecutionContext.createCatalog(ExecutionContext.java:396)
        at org.apache.flink.table.client.gateway.local.ExecutionContext.lambda$null$5(ExecutionContext.java:684)
        at java.util.HashMap.forEach(HashMap.java:1289)
```

解决: 重新编译flink，官方提供的hive-connect与hdp的hive版本不兼容，需要改成引用hdb版本的hive依赖库。

3.3 采用pre-job方式无法查询hive库，报错如下

```
无法访问org.apache.hadoop.mapred.JobConf
```

解决：参考附录，拷贝附录中的jar库。

### 附录

#### 1. 编译flink-sql-connector-hive

1.1 下载flink官方源码，https://github.com/apache/flink.git

1.2 从目标集群运行环境中获取hive-exec.jar

1.3  在目标编译环境中安装hive-exec.jar 包，

```
mvn install:install-file -DgroupId=org.apache.hive -DartifactId=hive-exec -Dversion=3.1.2.hdp -Dpackaging=jar -Dfile=./hive-exec.jar
```

1.4 修改flink-sql-connector-hive-3.1.2_2.11模块中的pom.xml依赖，将原hive-exe版本修改为上面步骤的版本，如3.1.2.hdp

1.5 执行编译命令

```
mvn clean package
```



### REF

https://www.cxyzjd.com/article/weixin_30755393/96369063