# Hive和Iceberg集成

## 兼容性矩阵

Iceberg 支持使用 StorageHandler 通过 Hive 读取和写入 Iceberg 表。以下是 Iceberg Hive 支持的当前兼容性矩阵：

| Feature               | Hive 2.x              | Hive 3.1.2            |
| :-------------------- | :-------------------- | :-------------------- |
| CREATE EXTERNAL TABLE | ✔️                     | ✔️                     |
| CREATE TABLE          | ✔️                     | ✔️                     |
| DROP TABLE            | ✔️                     | ✔️                     |
| SELECT                | ✔️ (MapReduce and Tez) | ✔️ (MapReduce and Tez) |
| INSERT INTO           | ✔️ (MapReduce only)️    | ✔️ (MapReduce only)    |

## 集成

#### 环境

```text
HDFS 3.1.1.3.1
Hive 2.x、3.1.2
Iceberg 0.12.0
```

#### 在 Hive 中启用Iceberg支持

(1) 如果使用Hive Shell

> 注：该方式作用是当前session可用

将iceberg-hive-runtime-*.jar上传到安装hive客户端的服务器上，并将文件上传到hdfs上：

```shell
hadoop fs -copyFromLocal iceberg-hive-runtime-5f90476.jar /user/hive/lib/
```

登陆hive的客户端，增加iceberg-hive-runtime-*.jar

```sql
0: jdbc:hive2://dev.bdp.mgmt01:2181,dev.bdp.m>  add jar hdfs://bdptest/user/hive/lib/iceberg-hive-runtime-5f90476.jar;
INFO  : Added [/tmp/98bd82f3-b34c-4695-a57d-7ac198818b95_resources/iceberg-hive-runtime-5f90476.jar] to class path
INFO  : Added resources: [hdfs://bdptest/user/hive/lib/iceberg-hive-runtime-5f90476.jar]
No rows affected (0.464 seconds)
```

（2）将 jar 文件添加到 Hive 的辅助类路径

> 注：该方式作用是**全局**默认情况下可用的

Hive的辅助类路径参见hive中的配置：`Auxillary JAR list`，未配置的话可以自定义配置一个。

![image-20210918172202168](assets/image-20210918172202168.png)

#### Catalog管理

iceberg的catalog的方式：

- 全局 Hive Catalog
- 自定义Catalog

这里我们统一选在按照默认的全局Hive Catalog。自定义Catalog方式参见[官网](https://iceberg.apache.org/hive/#custom-iceberg-catalogs)。

####  设置属性

登陆beeline客户端，增加以下属性：

```shell
set hive.vectorized.execution.enabled=false;  #禁用矢量化
set hive.execution.engine=mr;   #引擎改为mr，目前hive+iceberg不支持通过tez进行insert into操作，仅支持mr
set iceberg.mr.schema.auto.conversion=true; # Hive和Iceberg支持不同类型的类型，此属性为true，支持执行类型自动转换
```

#### 创建表

Hive 支持通过 CREATE TABLE 语句直接创建新的 Iceberg 表。例如：

```shell
CREATE TABLE database_a.table_a (
  id bigint, name string
) PARTITIONED BY (
  dept string
) STORED BY 'org.apache.iceberg.mr.hive.HiveIcebergStorageHandler';
```

#### 删除表

可以使用 `DROP TABLE` 命令删除表：

```sql
DROP TABLE [IF EXISTS] table_name [PURGE];
```

其中加上`PURGE`代表清除表中的所有数据和元数据

#### 查询

可以像正常sql一样查询表的数据，例如：

```sql
SELECT * from table_name;
```

#### 写数据

Hive 支持标准的单表 INSERT INTO 操作：

```sql
INSERT INTO table_a VALUES ('a', 1);
INSERT INTO table_a SELECT ...;
```

也支持多表插入，但它不是原子的，一次提交一张表。部分更改将在提交过程中可见，失败可能会导致部分更改被提交。单个表中的更改将保持原子性。

这是在 Hive SQL 中一次插入多个表的示例：

```sql
FROM customers
    INSERT INTO target1 SELECT customer_id, first_name
    INSERT INTO target2 SELECT last_name, customer_id;
```

## Hive 和 Iceberg 类型

此类型转换表描述了蜂巢类型如何转换为Iceberg类型。这种转换既适用于创建Iceberg表，也适用于通过Hive写入Iceberg表。

| Hive                | Iceberg                    | Notes           |
| :------------------ | :------------------------- | :-------------- |
| boolean             | boolean                    |                 |
| short               | integer                    | auto-conversion |
| byte                | integer                    | auto-conversion |
| integer             | integer                    |                 |
| long                | long                       |                 |
| float               | float                      |                 |
| double              | double                     |                 |
| date                | date                       |                 |
| timestamp           | timestamp without timezone |                 |
| timestamplocaltz    | timestamp with timezone    | Hive 3 only     |
| interval_year_month |                            | not supported   |
| interval_day_time   |                            | not supported   |
| char                | string                     | auto-conversion |
| varchar             | string                     | auto-conversion |
| string              | string                     |                 |
| binary              | binary                     |                 |
| decimal             | decimal                    |                 |
| struct              | struct                     |                 |
| list                | list                       |                 |
| map                 | map                        |                 |
| union               |                            | not supported   |

## FAQ

#### 1.hive 增加jar失败

通过hive cli或者beeline cli执行增加jar命令失败如下：

```sql
0: jdbc:hive2://dev.bdp.mgmt01:2181,dev.bdp.m> add jar /deploy/hive/iceberg-hive-runtime-5f90476.jar;
Error: Error while processing statement: Permission denied: Principal [name=root, type=USER] does not have following privileges for operation ADD [ADMIN] (state=,code=1)
```

原因：

由报错原因可以看出是权限相关问题。

解决：

在Ambari中将hive的`Enable Authorization`配置改为false。

参考：https://blog.csdn.net/weixin_41772761/article/details/117470025

#### 2.[Hive 删除包含表的数据库](https://blog.csdn.net/yulei_qq/article/details/82216230)

当删除一个hive 数据库时，若该 数据库时包含表，则会提示不能删除。

```shell
hive> drop  database test;
FAILED: Execution Error, return code 1 from org.apache.hadoop.hive.ql.exec.DDLTask. 
InvalidOperationException(message:Database test is not empty. One or more tables exist.)
```

此时，用户要么先删除数据库中的表，要么再删除数据库；要么在删除命令的最后面加上关键字CASCADE ，这样可以使hive自行先删除数据库中的表；

```shell
hive> DROP DATABASE TEST CASCADE;
OK
Time taken: 2.499 seconds
hive> show databases;
OK
default
ts
Time taken: 0.025 seconds, Fetched: 2 row(s)
```

#### 3.Hive: create and write iceberg by hive client, Hive client read no data

1.问题描述：

在集群hive beeline上进行iceberg的create table、insert into过程正常执行，select表结果为空。

过程详见issue：https://github.com/apache/iceberg/issues/3113

2.原因分析：

目前看到数据已经保存到hdfs上，但是metadata目录下只有元数据文件，无snapshot文件。数据查询为空的主要原因断定为无snapshot的文件导致

3.原因：

hive3执行引擎默认是tez，不再支持mapreduce，而iceberg官方还未支持tez的insert into操作

4.验证hive2+mr+iceberg的功能

建表、插入、查询结果正常，刚好验证了以上原因

![image.png](https://atlas.pingcode.com/files/public/6144022295f694cb7081ec40)

5.结论：

已解决，不能在hive3+tez执行iceberg的insert into 操作，和官方的说明一致。以下为官方的描述：

![image.png](https://atlas.pingcode.com/files/public/61440289b32ec35d774cdc9a)

#### 4.Hive beeline查询Flink写入的Iceberg表数据异常

1.环境：

```tex
hdfs:3.1.1.3.1
hive:3.1.0
iceberg:master branch build(2021/9/16)
```

2.问题描述：

（1）通过flink建hive catalog的Iceberg表iceberg_tb16，并插入数据，并通过flink查询正常

（2）通过hive beeline查询异常：

```sql
0: jdbc:hive2://dev.bdp.mgmt01:2181,dev.bdp.m>  add jar hdfs://bdptest/user/hive/lib/iceberg-hive-runtime-5f90476.jar;
INFO  : Added [/tmp/98bd82f3-b34c-4695-a57d-7ac198818b95_resources/iceberg-hive-runtime-5f90476.jar] to class path
INFO  : Added resources: [hdfs://bdptest/user/hive/lib/iceberg-hive-runtime-5f90476.jar]
No rows affected (0.464 seconds)
0: jdbc:hive2://dev.bdp.mgmt01:2181,dev.bdp.m> select * from iceberg_tb16;
INFO  : Compiling command(queryId=hive_20210916105413_bdc943e8-7017-479f-94de-381637a53922): select * from iceberg_tb16
INFO  : Semantic Analysis Completed (retrial = false)
INFO  : Returning Hive schema: Schema(fieldSchemas:[FieldSchema(name:iceberg_tb16.id, type:int, comment:null), FieldSchema(name:iceberg_tb16.name, type:string, comment:null), FieldSchema(name:iceberg_tb16.age, type:int, comment:null)], properties:null)
INFO  : Completed compiling command(queryId=hive_20210916105413_bdc943e8-7017-479f-94de-381637a53922); Time taken: 0.368 seconds
INFO  : Executing command(queryId=hive_20210916105413_bdc943e8-7017-479f-94de-381637a53922): select * from iceberg_tb16
INFO  : Completed executing command(queryId=hive_20210916105413_bdc943e8-7017-479f-94de-381637a53922); Time taken: 0.005 seconds
INFO  : OK
Error: java.lang.NoClassDefFoundError: org/apache/iceberg/SnapshotParser (state=,code=0)
```

3.原因分析：

由于Iceberg官网兼容性矩阵明确指定兼容hive2.x和hive3.1.2，而我们当前环境为hive3.1.0，与iceberg不兼容。为此在集群上安装一个hive3.1.2的客户端进行验证，结果是可以查询iceberg的表。验证如下图所示：

![image.png](assets/origin-url.png)


## Ref

- 【Hive+Iceberg】https://iceberg.apache.org/hive/#type-compatibility

