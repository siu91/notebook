# StarRocks 的核心功能特性

## 联邦查询（外表）

### Hive外表

#### 创建Hive资源

一个Hive资源对应一个Hive集群，管理StarRocks使用的Hive集群相关配置，如Hive meta store地址等。创建Hive外表的时候需要指定使用哪个Hive资源。

```sql
-- 创建一个名为hive0的Hive资源
CREATE EXTERNAL RESOURCE "hive0"
PROPERTIES (
  "type" = "hive",
  "hive.metastore.uris" = "thrift://10.10.44.98:9083"
);

-- 查看StarRocks中创建的资源
SHOW RESOURCES;

-- 删除名为hive0的资源
DROP RESOURCE "hive0";
```

#### 创建数据库

```sql
CREATE DATABASE hive_test;
USE hive_test;
```

#### 创建Hive外表

```sql
-- 语法
CREATE EXTERNAL TABLE table_name (
  col_name col_type [NULL | NOT NULL] [COMMENT "comment"]
) ENGINE=HIVE
PROPERTIES (
  "key" = "value"
);

-- 例子：创建hive0资源对应的Hive集群中rawdata数据库下的profile_parquet_p7表的外表
CREATE EXTERNAL TABLE `profile_wos_p7` (
  `id` bigint NULL,
  `first_id` varchar(200) NULL,
  `second_id` varchar(200) NULL,
  `p__device_id_list` varchar(200) NULL,
  `p__is_deleted` bigint NULL,
  `p_channel` varchar(200) NULL,
  `p_platform` varchar(200) NULL,
  `p_source` varchar(200) NULL,
  `p__city` varchar(200) NULL,
  `p__province` varchar(200) NULL,
  `p__update_time` bigint NULL,
  `p__first_visit_time` bigint NULL,
  `p__last_seen_time` bigint NULL
) ENGINE=HIVE
PROPERTIES (
  "resource" = "hive0",
  "database" = "rawdata",
  "table" = "profile_parquet_p7"
);
```

说明：

- 外表列：

  - 列名需要与Hive表一一对应。
  - 列的顺序**不需要**与Hive表一致。
  - 可以只选择Hive表中的**部分列**，但**分区列**必须要全部包含。
  - 外表的分区列无需通过partition by语句指定，需要与普通列一样定义到描述列表中。不需要指定分区信息，StarRocks会自动从Hive同步。
  - ENGINE指定为HIVE。

- PROPERTIES属性：

  - **hive.resource**：指定使用的Hive资源。
  - **database**：指定Hive中的数据库。
  - **table**：指定Hive中的表，**不支持view**。

- 支持的列类型对应关系如下表：

  | Hive列类型  | StarRocks列类型 | 描述                                                         |
  | :---------- | :-------------- | :----------------------------------------------------------- |
  | INT/INTEGER | INT             |                                                              |
  | BIGINT      | BIGINT          |                                                              |
  | TIMESTAMP   | DATETIME        | Timestamp转成Datetime，会损失精度和时区信息， 根据sessionVariable中的时区转成无时区Datatime |
  | STRING      | VARCHAR         |                                                              |
  | VARCHAR     | VARCHAR         |                                                              |
  | CHAR        | CHAR            |                                                              |
  | DOUBLE      | DOUBLE          |                                                              |
  | FLOATE      | FLOAT           |                                                              |

  说明：

  - Hive表Schema变更**不会自动同步**，需要在StarRocks中重建Hive外表。
  - 当前Hive的存储格式仅支持Parquet和ORC类型
  - 压缩格式支持snappy，lz4

###### 查询Hive外表

```sql
-- 查询profile_wos_p7的总行数
select count(*) from profile_wos_p7;
```

## 物化视图

### 创建物化视图

通过下面命令就可以创建物化视图。创建物化视图是一个异步的操作，也就是说用户成功提交创建任务后，StarRocks 会在后台对存量的数据进行计算，直到创建成功。

```sql
CREATE MATERIALIZED VIEW
```

具体的语法可以通过下面命令查看：

```sql
HELP CREATE MATERIALIZED VIEW
```

假设用户有一张销售记录明细表，存储了每个交易的交易id、销售员、售卖门店、销售时间、以及金额。建表语句为：

```sql
CREATE TABLE sales_records(
    record_id int,
    seller_id int,
    store_id int,
    sale_date date,
    sale_amt bigint
) distributed BY hash(record_id)
properties("replication_num" = "1");
```

表 sales_records 的结构为:

```plaintext
MySQL [test]> desc sales_records;

+-----------+--------+------+-------+---------+-------+
| Field     | Type   | Null | Key   | Default | Extra |
+-----------+--------+------+-------+---------+-------+
| record_id | INT    | Yes  | true  | NULL    |       |
| seller_id | INT    | Yes  | true  | NULL    |       |
| store_id  | INT    | Yes  | true  | NULL    |       |
| sale_date | DATE   | Yes  | false | NULL    | NONE  |
| sale_amt  | BIGINT | Yes  | false | NULL    | NONE  |
+-----------+--------+------+-------+---------+-------+
```

如果用户经常对不同门店的销售量做分析，则可以为 sales_records 表创建一张“以售卖门店为分组，对相同售卖门店的销售额求和”的物化视图。创建语句如下：

```sql
CREATE MATERIALIZED VIEW store_amt AS
SELECT store_id, SUM(sale_amt)
FROM sales_records
GROUP BY store_id;
```

更详细物化视图创建语法请参看SQL参考手册 [CREATE MATERIALIZED VIEW](https://docs.starrocks.com/zh-cn/main/sql-reference/sql-statements/data-definition/CREATE MATERIALIZED VIEW) ，或者在 MySQL 客户端使用命令 `help create materialized view` 获得帮助。

### 查看物化视图

由于创建物化视图是一个异步的操作，用户在提交完创建物化视图任务后，需要通过命令检查物化视图是否构建完成，命令如下:

```sql
SHOW ALTER MATERIALIZED VIEW FROM db_name;
```

或

```sql
SHOW ALTER TABLE ROLLUP FROM db_name;
```

> db_name：替换成真实的 db name，比如"test"。

查询结果为:

```plaintext
+-------+---------------+---------------------+---------------------+---------------+-----------------+----------+---------------+----------+------+----------+---------+
| JobId | TableName     | CreateTime          | FinishedTime        | BaseIndexName | RollupIndexName | RollupId | TransactionId | State    | Msg  | Progress | Timeout |
+-------+---------------+---------------------+---------------------+---------------+-----------------+----------+---------------+----------+------+----------+---------+
| 22324 | sales_records | 2020-09-27 01:02:49 | 2020-09-27 01:03:13 | sales_records | store_amt       | 22325    | 672           | FINISHED |      | NULL     | 86400   |
+-------+---------------+---------------------+---------------------+---------------+-----------------+----------+---------------+----------+------+----------+---------+
```

如果 State 为 FINISHED，说明物化视图已经创建完成。

查看物化视图的表结果，需用通过基表名进行：

```plaintext
mysql> desc sales_records all;

+---------------+---------------+-----------+--------+------+-------+---------+-------+
| IndexName     | IndexKeysType | Field     | Type   | Null | Key   | Default | Extra |
+---------------+---------------+-----------+--------+------+-------+---------+-------+
| sales_records | DUP_KEYS      | record_id | INT    | Yes  | true  | NULL    |       |
|               |               | seller_id | INT    | Yes  | true  | NULL    |       |
|               |               | store_id  | INT    | Yes  | true  | NULL    |       |
|               |               | sale_date | DATE   | Yes  | false | NULL    | NONE  |
|               |               | sale_amt  | BIGINT | Yes  | false | NULL    | NONE  |
|               |               |           |        |      |       |         |       |
| store_amt     | AGG_KEYS      | store_id  | INT    | Yes  | true  | NULL    |       |
|               |               | sale_amt  | BIGINT | Yes  | false | NULL    | SUM   |
+---------------+---------------+-----------+--------+------+-------+---------+-------+
```



### 查询命中物化视图

当物化视图创建完成后，用户再查询不同门店的销售量时，就会直接从刚才创建的物化视图 store_amt 中读取聚合好的数据，达到提升查询效率的效果。

用户的查询依旧指定查询 sales_records 表，比如：

```sql
SELECT store_id, SUM(sale_amt) FROM sales_records GROUP BY store_id;
```

使用 EXPLAIN 命令查询物化视图是否命中：

```sql
EXPLAIN SELECT store_id, SUM(sale_amt) FROM sales_records GROUP BY store_id;
```

结果为:

```plaintext
| Explain String                                                              |
+-----------------------------------------------------------------------------+
| PLAN FRAGMENT 0                                                             |
|  OUTPUT EXPRS:<slot 2> `store_id` | <slot 3> sum(`sale_amt`)                |
|   PARTITION: UNPARTITIONED                                                  |
|                                                                             |
|   RESULT SINK                                                               |
|                                                                             |
|   4:EXCHANGE                                                                |
|      use vectorized: true                                                   |
|                                                                             |
| PLAN FRAGMENT 1                                                             |
|  OUTPUT EXPRS:                                                              |
|   PARTITION: HASH_PARTITIONED: <slot 2> `store_id`                          |
|                                                                             |
|   STREAM DATA SINK                                                          |
|     EXCHANGE ID: 04                                                         |
|     UNPARTITIONED                                                           |
|                                                                             |
|   3:AGGREGATE (merge finalize)                                              |
|   |  output: sum(<slot 3> sum(`sale_amt`))                                  |
|   |  group by: <slot 2> `store_id`                                          |
|   |  use vectorized: true                                                   |
|   |                                                                         |
|   2:EXCHANGE                                                                |
|      use vectorized: true                                                   |
|                                                                             |
| PLAN FRAGMENT 2                                                             |
|  OUTPUT EXPRS:                                                              |
|   PARTITION: RANDOM                                                         |
|                                                                             |
|   STREAM DATA SINK                                                          |
|     EXCHANGE ID: 02                                                         |
|     HASH_PARTITIONED: <slot 2> `store_id`                                   |
|                                                                             |
|   1:AGGREGATE (update serialize)                                            |
|   |  STREAMING                                                              |
|   |  output: sum(`sale_amt`)                                                |
|   |  group by: `store_id`                                                   |
|   |  use vectorized: true                                                   |
|   |                                                                         |
|   0:OlapScanNode                                                            |
|      TABLE: sales_records                                                   |
|      PREAGGREGATION: ON                                                     |
|      partitions=1/1                                                         |
|      rollup: store_amt                                                      |
|      tabletRatio=10/10                                                      |
|      tabletList=22326,22328,22330,22332,22334,22336,22338,22340,22342,22344 |
|      cardinality=0                                                          |
|      avgRowSize=0.0                                                         |
|      numNodes=1                                                             |
|      use vectorized: true                                                   |
+-----------------------------------------------------------------------------+
```

查询计划树中的 OlapScanNode 显示 `PREAGGREGATION: ON` 和 `rollup: store_amt`，说明使用物化视图 store_amt 的预先聚合计算结果。也就是说查询已经命中到物化视图 store_amt，并直接从物化视图中读取数据了。



### 删除物化视图

下列两种情形需要删除物化视图:

- 用户误操作创建物化视图，需要撤销该操作。
- 用户创建了大量的物化视图，导致数据导入速度过慢不满足业务需求，并且部分物化视图的相互重复，查询频率极低，可容忍较高的查询延迟，此时需要删除部分物化视图。

删除已经创建完成的物化视图:

```sql
DROP MATERIALIZED VIEW IF EXISTS store_amt on sales_records;
```

删除处于创建中的物化视图，需要先取消异步任务，然后再删除物化视图，以表 `db0.table0` 上的物化视图 mv 为例:

首先获得JobId，执行命令:

```sql
show alter table rollup from db0;
```

结果为:

```plaintext
+-------+---------------+---------------------+---------------------+---------------+-----------------+----------+---------------+-------------+------+----------+---------+
| JobId | TableName     | CreateTime          | FinishedTime        | BaseIndexName | RollupIndexName | RollupId | TransactionId | State       | Msg  | Progress | Timeout |
| 22478 | table0        | 2020-09-27 01:46:42 | NULL                | table0        | mv              | 22479    | 676           | WAITING_TXN |      | NULL     | 86400   |
+-------+---------------+---------------------+---------------------+---------------+-----------------+----------+---------------+-------------+------+----------+---------+
```

其中JobId为22478，取消该Job，执行命令:

```sql
cancel alter table rollup from db0.table0 (22478);
```

## bitmap、HLL 去重

### 用Bitmap实现精确去重

以统计某一个页面的UV为例：

首先，创建一张含有BITMAP列的表，其中visit_users列为聚合列，列类型为BITMAP，聚合函数为BITMAP_UNION

```sql
CREATE TABLE `page_uv` (
  `page_id` INT NOT NULL COMMENT '页面id',
  `visit_date` datetime NOT NULL COMMENT '访问时间',
  `visit_users` BITMAP BITMAP_UNION NOT NULL COMMENT '访问用户id'
) ENGINE=OLAP
AGGREGATE KEY(`page_id`, `visit_date`)
DISTRIBUTED BY HASH(`page_id`) BUCKETS 1
PROPERTIES (
  "replication_num" = "1",
  "storage_format" = "DEFAULT"
);
```

向表中导入数据，采用insert into语句导入

```sql
insert into page_uv values
(1, '2020-06-23 01:30:30', to_bitmap(13)),
(1, '2020-06-23 01:30:30', to_bitmap(23)),
(1, '2020-06-23 01:30:30', to_bitmap(33)),
(1, '2020-06-23 02:30:30', to_bitmap(13)),
(2, '2020-06-23 01:30:30', to_bitmap(23));
```

在以上数据导入后，在 page_id = 1， visit_date = '2020-06-23 01:30:30'的数据行，visit_user字段包含着3个bitmap元素（13，23，33）；在page_id = 1， visit_date = '2020-06-23 02:30:30'的数据行，visit_user字段包含着1个bitmap元素（13）；在page_id = 2， visit_date = '2020-06-23 01:30:30'的数据行，visit_user字段包含着1个bitmap元素（23）。

统计每个页面的UV

```sql
select page_id, count(distinct visit_users) from page_uv group by page_id;
```

查询结果

```shell
mysql> select page_id, count(distinct visit_users) from page_uv group by page_id;

+-----------+------------------------------+
|  page_id  | count(DISTINCT `visit_user`) |
+-----------+------------------------------+
|         1 |                            3 |
+-----------+------------------------------+
|         2 |                            1 |
+-----------+------------------------------+
2 row in set (0.00 sec)
```

### 用HLL实现近似去重

首先，创建一张含有**HLL**列的表，其中uv列为聚合列，列类型为HLL，聚合函数为HLL_UNION

```sql
CREATE TABLE test(
        dt DATE,
        id INT,
        uv HLL HLL_UNION
)
DISTRIBUTED BY HASH(ID) BUCKETS 32;
```

查询数据

- HLL列不允许直接查询它的原始值，可以用函数HLL_UNION_AGG进行查询
- 求总uv

```
SELECT HLL_UNION_AGG(uv) FROM test;
```

该语句等价于

```
SELECT COUNT(DISTINCT uv) FROM test;
```

- 求每一天的uv

```
SELECT COUNT(DISTINCT uv) FROM test GROUP BY dt;
```

## 画像、标签场景功能（数组）

### 数组定义

下面是在StarRocks中定义数组列的例子

```sql
-- 一维数组
create table t0(   c0 INT,   c1 ARRAY<INT> ) duplicate key(c0) DISTRIBUTED BY HASH(c0) BUCKETS 3;

```

数组类型有以下限制

- 只能在duplicate table中定义数组列
- 数组列不能作为key列(以后可能支持)
- 数组列不能作为distribution列
- 数组列不能作为partition列



### 在SQL中构造数组

可以在SQL中通过中括号（ "[" 和 "]" ）来构造数组常量，每个数组元素通过逗号(",")分割

```sql
select [1, 2, 3] as numbers;
select ["apple", "orange", "pear"] as fruit;
select [true, false] as booleans;
```

当数组元素具有不同类型时，StarRocks会自动推导出合适的类型(supertype)

```sql
select [1, 1.2] as floats;
select [12, "100"]; -- 结果是 ["12", "100"]
```

可以使用尖括号(`<>`)显示声明数组类型

```sql
select `ARRAY<float>`[1, 2];
select `ARRAY<INT>`["12", "100"]; -- 结果是 [12, 100]
```

元素中可以包含NULL

```sql
select [1, NULL];
```

对于空数组，可以使用尖括号显示声明其类型，也可以直接写[]，此时StarRocks会根据上下文推断其类型，如果无法推断则会报错。

```sql
select [];
select `ARRAY<VARCHAR(10)>`[];
select array_append([], 10);
```



### 数组导入

目前有三种方式向StarRocks中写入数组值，insert into 适合小规模数据测试。后面两种适合大规模数据导入。

- **INSERT INTO**

  ```sql
  create table t0(   c0 INT,   c1 ARRAY<INT> ) duplicate key(c0) DISTRIBUTED BY HASH(c0) BUCKETS 3;
  INSERT INTO t0 VALUES(1, [1,2,3]);
  ```

- **从ORC Parquet文件导入**

  StarRocks 中的数组类型，与ORC/Parquet格式中的list结构相对应，不需要额外指定，具体请参考StarRocks 企业文档中 `broker load` 导入相关章节。当前ORC的list结构可以直接导入，Parquet格式正在开发中。

- **从CSV文件导入**

  CSV 文件导入数组，默认采用逗号分隔, 可以用 stream load / routine load 导入CSV文本文件或 Kafka 中的 CSV 格式数据。

### 数组元素访问

使用中括号（ "[" 和 "]" ）加下标形式访问数组中某个元素，下标从 `1` 开始

```plaintext
mysql> select [1,2,3][1];

+------------+
| [1,2,3][1] |
+------------+
|          1 |
+------------+
1 row in set (0.00 sec)
```

如果下标为0，或者为负数，**不会报错，会返回NULL**

```plaintext
mysql> select [1,2,3][0];

+------------+
| [1,2,3][0] |
+------------+
|       NULL |
+------------+
1 row in set (0.01 sec)
```

如果下标超过数组大小，**也会返回NULL**

```plaintext
mysql> select [1,2,3][4];

+------------+
| [1,2,3][4] |
+------------+
|       NULL |
+------------+
1 row in set (0.01 sec)
```

对于多维数组，可以**递归**访问内部元素

```plaintext
mysql(ARRAY)> select [[1,2],[3,4]][2];

+------------------+
| [[1,2],[3,4]][2] |
+------------------+
| [3,4]            |
+------------------+
1 row in set (0.00 sec)

mysql> select [[1,2],[3,4]][2][1];

+---------------------+
| [[1,2],[3,4]][2][1] |
+---------------------+
|                   3 |
+---------------------+
1 row in set (0.01 sec)
```

## CBO 优化器

### 启用统计信息自动抽样收集

所以开启新优化器前，需要先开启统计信息收集。启用统计信息自动抽样收集方式：

修改 FE Config ：

```apache
enable_statistic_collect = true
```

然后重启FE。

### 查询启用新优化器

> 注意：启用新优化器之前，建议先开启统计信息自动抽样收集 1 ~ 2天。

全局粒度开启：

```sql
set global enable_cbo = true;
```

Session 粒度开启：

```sql
set enable_cbo = true;
```

单个 SQL 粒度开启：

```sql
SELECT /*+ SET_VAR(enable_cbo = true) */ * from table;
```

## 窗口函数

## 使用方式

窗口函数的语法：

```sql
function(args) OVER(partition_by_clause order_by_clause [window_clause])
partition_by_clause ::= PARTITION BY expr [, expr ...]
order_by_clause ::= ORDER BY expr [ASC | DESC] [, expr [ASC | DESC] ...]
```

### Function

目前支持的Function包括：

- MIN(), MAX(), COUNT(), SUM(), AVG()
- FIRST_VALUE(), LAST_VALUE(), LEAD(), LAG()
- ROW_NUMBER(), RANK(), DENSE_RANK()

### PARTITION BY从句

Partition By从句和Group By类似。它把输入行按照指定的一列或多列分组，相同值的行会被分到一组。

### ORDER BY从句

Order By从句和外层的Order By基本一致。它定义了输入行的排列顺序，如果指定了Partition By，则Order By定义了每个Partition分组内的顺序。与外层Order By的唯一不同点是：OVER从句中的`Order By n`（n是正整数）相当于不做任何操作，而外层的Order By n表示按照第n列排序。

举例:

这个例子展示了在select列表中增加一个id列，它的值是1，2，3等等，顺序按照events表中的date_and_time列排序。

```sql
SELECT row_number() OVER (ORDER BY date_and_time) AS id,
    c1, c2, c3, c4
FROM events;
```

### Window Clause

Window从句用来为窗口函数指定一个运算范围，以当前行为准，前后若干行作为窗口函数运算的对象。Window从句支持的方法有：AVG(), COUNT(), FIRST_VALUE(), LAST_VALUE()和SUM()。对于 MAX()和MIN(), window从句可以指定开始范围UNBOUNDED PRECEDING

语法：

```sql
ROWS BETWEEN [ { m | UNBOUNDED } PRECEDING | CURRENT ROW] [ AND [CURRENT ROW | { UNBOUNDED | n } FOLLOWING] ]
```

举例：

假设我们有如下的股票数据，股票代码是JDR，closing price是每天的收盘价。

```sql
create table stock_ticker (
    stock_symbol string,
    closing_price decimal(8,2),
    closing_date timestamp);

-- ...load some data...

select *
from stock_ticker
order by stock_symbol, closing_date
```

得到原始数据如下：

```plaintext
+--------------+---------------+---------------------+
| stock_symbol | closing_price | closing_date        |
+--------------+---------------+---------------------+
| JDR          | 12.86         | 2014-10-02 00:00:00 |
| JDR          | 12.89         | 2014-10-03 00:00:00 |
| JDR          | 12.94         | 2014-10-04 00:00:00 |
| JDR          | 12.55         | 2014-10-05 00:00:00 |
| JDR          | 14.03         | 2014-10-06 00:00:00 |
| JDR          | 14.75         | 2014-10-07 00:00:00 |
| JDR          | 13.98         | 2014-10-08 00:00:00 |
+--------------+---------------+---------------------+
```

这个查询使用窗口函数产生moving_average这一列，它的值是3天的股票均价，即前一天、当前以及后一天三天的均价。第一天没有前一天的值，最后一天没有后一天的值，所以这两行只计算了两天的均值。这里Partition By没有起到作用，因为所有的数据都是JDR的数据，但如果还有其他股票信息，Partition By会保证窗口函数值作用在本Partition之内。

```sql
select stock_symbol, closing_date, closing_price,
    avg(closing_price)
        over (partition by stock_symbol
              order by closing_date
              rows between 1 preceding and 1 following
        ) as moving_average
from stock_ticker;
```

得到如下数据：

```plaintext
+--------------+---------------------+---------------+----------------+
| stock_symbol | closing_date        | closing_price | moving_average |
+--------------+---------------------+---------------+----------------+
| JDR          | 2014-10-02 00:00:00 | 12.86         | 12.87          |
| JDR          | 2014-10-03 00:00:00 | 12.89         | 12.89          |
| JDR          | 2014-10-04 00:00:00 | 12.94         | 12.79          |
| JDR          | 2014-10-05 00:00:00 | 12.55         | 13.17          |
| JDR          | 2014-10-06 00:00:00 | 14.03         | 13.77          |
| JDR          | 2014-10-07 00:00:00 | 14.75         | 14.25          |
| JDR          | 2014-10-08 00:00:00 | 13.98         | 14.36          |
+--------------+---------------------+---------------+----------------+
```

## Lateral Join

## 使用说明

使用lateral join 需要打开新版优化器：

```sql
set global enable_cbo = true;
```

Lateral 关键字语法说明：

```sql
from table_reference join [lateral] table_reference
```

Unnest关键字，是一种 table function，可以把数组类型转化成table的多行，配合 Lateral Join 就能实现我们常见的各种行展开逻辑。

```sql
SELECT student, score
FROM tests
CROSS JOIN LATERAL UNNEST(scores) AS t (score);

SELECT student, score
FROM tests, UNNEST(scores) AS t (score);
```

这里第二种写法是第一种的简写，可以使用Unnest 关键字省略 Lateral Join。

## 批量导出

### 使用示例

#### 提交导出作业

数据导出命令的详细语法可以通过 `HELP EXPORT` 查看。导出作业举例如下：

```sql
EXPORT TABLE db1.tbl1 
PARTITION (p1,p2)
TO "hdfs://host/path/to/export/lineorder_" 
PROPERTIES
(
    "column_separator"=",",
    "exec_mem_limit"="2147483648",
    "timeout" = "3600"
)
WITH BROKER "hdfs"//部署broker的名称
(
    "username" = "user",//hdfs服务器的用户名
    "password" = "passwd",//hdfs服务器的用户名
);
```

导出路径**如果指定到目录**，需要指定最后的`/`，否则最后的部分会被当做导出文件的前缀。不指定前缀默认为`data_`。 示例中导出文件会生成到 export 目录中，文件前缀为 `lineorder_`。

PROPERTIES如下：

- `column_separator`：列分隔符。默认为 `\t`。
- `line_delimiter`：行分隔符。默认为 `\n`。
- `exec_mem_limit`： 表示 Export 作业中，**一个查询计划**在**单个 BE** 上的内存使用限制。默认 2GB。单位字节。
- `timeout`：作业超时时间。默认为 2 小时。单位秒。
- `include_query_id`: 导出文件名中是否包含 query id，默认为 true。

### 获取导出作业 query id

提交作业后，可以通过 `SELECT LAST_QUERY_ID()` 命令获得导出作业的 query id。用户可以通过 query id 查看或者取消作业。

### 查看导出作业状态

提交作业后，可以通过 `SHOW EXPORT` 命令查询导出作业状态。

```sql
SHOW EXPORT WHERE queryid = "921d8f80-7c9d-11eb-9342-acde48001122";
```

结果举例如下：

```sql
     JobId: 14008
     State: FINISHED
  Progress: 100%
  TaskInfo: {"partitions":["*"],"exec mem limit":2147483648,"column separator":",","line delimiter":"\n","tablet num":1,"broker":"hdfs","coord num":1,"db":"default_cluster:db1","tbl":"tbl3"}
      Path: oss://bj-test/export/
CreateTime: 2019-06-25 17:08:24
 StartTime: 2019-06-25 17:08:28
FinishTime: 2019-06-25 17:08:34
   Timeout: 3600
  ErrorMsg: N/A
```

- JobId：作业的唯一 ID
- State：作业状态：
  - PENDING：作业待调度
  - EXPORING：数据导出中
  - FINISHED：作业成功
  - CANCELLED：作业失败
- Progress：作业进度。该进度以查询计划为单位。假设一共 10 个查询计划，当前已完成 3 个，则进度为 30%。
- TaskInfo：以 Json 格式展示的作业信息：
  - db：数据库名
  - tbl：表名
  - partitions：指定导出的分区。*表示所有分区。
  - exec mem limit：查询的内存使用限制。单位字节。
  - column separator：导出文件的列分隔符。
  - line delimiter：导出文件的行分隔符。
  - tablet num：涉及的总 Tablet 数量。
  - broker：使用的 broker 的名称。
  - coord num：查询计划的个数。
- Path：远端存储上的导出路径。
- CreateTime/StartTime/FinishTime：作业的创建时间、开始调度时间和结束时间。
- Timeout：作业超时时间。单位是「秒」。该时间从 CreateTime 开始计算。
- ErrorMsg：如果作业出现错误，这里会显示错误原因。

#### 取消作业

举例如下：

```sql
CANCEL EXPORT WHERE queryid = "921d8f80-7c9d-11eb-9342-acde48001122";
```

## 数据导入

### Stream load

#### 导入示例

##### 创建导入任务

Stream Load 通过 HTTP 协议提交和传输数据。这里通过 curl 命令展示如何提交导入。用户也可以通过其他HTTP client进行操作。

**语法：**

```bash
curl --location-trusted -u user:passwd [-H ""...] -T data.file -XPUT \
    http://fe_host:http_port/api/{db}/{table}/_stream_load
```

Header中支持的属性见下文的导入任务参数说明，格式为: -H "key1:value1"。如果同时有多个任务参数，需要用多个 -H 来指示，类似于 -H "key1:value1" -H "key2:value2"……

**示例：**

```bash
curl --location-trusted -u root -T date -H "label:123" \
    http://abc.com:8030/api/test/date/_stream_load
```

创建导入任务的详细语法可执行HELP STREAM LOAD查看，下面介绍该命令中部分参数的意义。

**说明：**

- 当前支持HTTP chunked与非chunked上传两种方式，对于非chunked方式，必须要有Content-Length来标示上传内容长度，这样能够保证数据的完整性。
- 用户最好设置Expect Header字段内容100-continue，这样可以在某些出错场景下避免不必要的数据传输。

**签名参数：**

- user/passwd，Stream Load创建导入任务使用的是HTTP协议，可通过 Basic access authentication 进行签名。StarRocks 系统会根据签名来验证用户身份和导入权限。

**导入任务参数：**

Stream Load 中所有与导入任务相关的参数均设置在 Header 中。下面介绍其中部分参数的意义：

- **label** :导入任务的标签，相同标签的数据无法多次导入。用户可以通过指定Label的方式来避免一份数据重复导入的问题。当前StarRocks系统会保留最近30分钟内成功完成的任务的Label。
- **column_separator** ：用于指定导入文件中的列分隔符，默认为\t。如果是不可见字符，则需要加\x作为前缀，使用十六进制来表示分隔符。如Hive文件的分隔符\x01，需要指定为-H "column-separator:\x01"
- **row_delimiter**: 用户指定导入文件中的行分隔符，默认为\n。
- **columns** ：用于指定导入文件中的列和 table 中的列的对应关系。如果源文件中的列正好对应表中的内容，那么无需指定该参数。如果源文件与表schema不对应，那么需要这个参数来配置数据转换规则。这里有两种形式的列，一种是直接对应于导入文件中的字段，可直接使用字段名表示；一种需要通过计算得出。举几个例子帮助理解：
  - 例1：表中有3列"c1, c2, c3"，源文件中的3列依次对应的是"c3,c2,c1"; 那么需要指定-H "columns: c3, c2, c1"
  - 例2：表中有3列"c1, c2, c3" ，源文件中前3列一一对应，但是还有多余1列；那么需要指定-H "columns: c1, c2, c3, temp"，最后1列随意指定名称用于占位即可。
  - 例3：表中有3个列“year, month, day"，源文件中只有一个时间列，为”2018-06-01 01:02:03“格式；那么可以指定 -H "columns: col, year = year(col), month=month(col), day=day(col)"完成导入。
- **where**: 用于抽取部分数据。用户如需将不需要的数据过滤掉，那么可以通过设定这个选项来达到。
  - 例1：只导入k1列等于20180601的数据，那么可以在导入时指定-H "where: k1 = 20180601"。
- **max_filter_ratio**：最大容忍可过滤（数据不规范等原因而过滤）的数据比例。默认零容忍。数据不规范不包括通过 where 条件过滤掉的行。
- **partitions**: 用于指定这次导入所涉及的partition。如果用户能够确定数据对应的partition，推荐指定该项。不满足这些分区的数据将被过滤掉。比如指定导入到p1、p2分区：-H "partitions: p1, p2"。
- **timeout**: 指定导入的超时时间。单位秒，默认是 600 秒。可设置范围为 1 秒 ~ 259200 秒。
- **strict_mode**: 用户指定此次导入是否开启严格模式，默认为开启。关闭方式为：-H "strict_mode: false"。
- **timezone**: 指定本次导入所使用的时区。默认为东八区。该参数会影响所有导入涉及的和时区有关的函数结果。
- **exec_mem_limit**: 导入内存限制。默认为 2GB。单位是「字节」。

### Routine Load

#### 导入示例

##### 环境要求

- 支持访问无认证或使用 SSL 方式认证的 Kafka 集群。
- 支持的消息格式为 CSV 文本格式，每一个 message 为一行，且行尾**不包含**换行符。
- 仅支持 Kafka 0.10.0.0(含) 以上版本。

#### 创建导入任务

**语法：**

```sql
CREATE ROUTINE LOAD [database.][job_name] ON [table_name]
    [COLUMNS TERMINATED BY "column_separator" ,]
    [COLUMNS (col1, col2, ...) ,]
    [WHERE where_condition ,]
    [PARTITION (part1, part2, ...)]
    [PROPERTIES ("key" = "value", ...)]
    FROM [DATA_SOURCE]
    [(data_source_properties1 = 'value1', 
    data_source_properties2 = 'value2', 
    ...)]
```

**示例：**

以从一个本地Kafka集群导入数据为例：

```sql
CREATE ROUTINE LOAD routine_load_wikipedia ON routine_wiki_edit
COLUMNS TERMINATED BY ",",
COLUMNS (event_time, channel, user, is_anonymous, is_minor, is_new, is_robot, is_unpatrolled, delta, added, deleted)
PROPERTIES
(
    "desired_concurrent_number"="1",
    "max_error_number"="1000"
)
FROM KAFKA
(
    "kafka_broker_list"= "localhost:9092",
    "kafka_topic" = "starrocks-load"
);
```

**说明：**

- **job_name**：必填。导入作业的名称，前缀可以携带导入数据库名称，常见命名方式为时间戳+表名。 单个 database 内，任务名称不可重复。
- **table_name**：必填。导入的目标表的名称。
- **COLUMN TERMINATED子句**：选填。指定源数据文件中的列分隔符，分隔符默认为：\t。
- **COLUMN子句** ：选填。用于指定源数据中列和表中列的映射关系。
  - 映射列：如目标表有三列 col1, col2, col3 ，源数据有4列，其中第1、2、4列分别对应col2, col1, col3，则书写如下：COLUMNS (col2, col1, temp, col3), ，其中 temp 列为不存在的一列，用于跳过源数据中的第三列。
  - 衍生列：除了直接读取源数据的列内容之外，StarRocks还提供对数据列的加工操作。假设目标表后加入了第四列 col4 ，其结果由 col1 + col2 产生，则可以书写如下：COLUMNS (col2, col1, temp, col3, col4 = col1 + col2),。
- **WHERE子句**：选填。用于指定过滤条件，可以过滤掉不需要的行。过滤条件可以指定映射列或衍生列。例如只导入 k1 大于 100 并且 k2 等于 1000 的行，则书写如下：WHERE k1 > 100 and k2 = 1000
- **PARTITION子句**：选填。指定导入目标表的哪些 partition 中，如果不指定，则会自动导入到对应的 partition 中。
- **PROPERTIES子句**：选填。用于指定导入作业的通用参数。
- **desired_concurrent_number**：导入并发度，指定一个导入作业最多会被分成多少个子任务执行。必须大于0，默认为3。
- **max_batch_interval**：每个子任务最大执行时间，单位是「秒」。范围为 5 到 60。默认为10。**1.15版本后**: 该参数是子任务的调度时间，即任务多久执行一次，任务的消费数据时间为fe.conf中的routine_load_task_consume_second，默认为3s， 任务的执行超时时间为fe.conf中的routine_load_task_timeout_second，默认为15s。
- **max_batch_rows**：每个子任务最多读取的行数。必须大于等于200000。默认是200000。**1.15版本后**: 该参数只用于定义错误检测窗口范围，窗口的范围是10 * **max-batch-rows**。
- **max_batch_size**：每个子任务最多读取的字节数。单位是「字节」，范围是 100MB 到 1GB。默认是 100MB。**1.15版本后**: 废弃该参数，任务消费数据的时间为fe.conf中的routine_load_task_consume_second，默认为3s。
- **max_error_number**：采样窗口内，允许的最大错误行数。必须大于等于0。默认是 0，即不允许有错误行。注意：被 where 条件过滤掉的行不算错误行。
- **strict_mode**：是否开启严格模式，默认为开启。如果开启后，非空原始数据的列类型变换如果结果为 NULL，则会被过滤，关闭方式为 "strict_mode" = "false"。
- **timezone**：指定导入作业所使用的时区。默认为使用 Session 的 timezone 参数。该参数会影响所有导入涉及的和时区有关的函数结果。
- **DATA_SOURCE**：指定数据源，请使用KAFKA。
- **data_source_properties**: 指定数据源相关的信息。
  - **kafka_broker_list**：Kafka 的 broker 连接信息，格式为 ip:host。多个broker之间以逗号分隔。
  - **kafka_topic**：指定要订阅的 Kafka 的 topic。
  - **kafka_partitions/kafka_offsets**：指定需要订阅的 kafka partition，以及对应的每个 partition 的起始 offset。
  - **property**：此处的属性，主要是kafka相关的属性，功能等同于kafka shell中 "--property" 参数。

创建导入任务更详细的语法可以通过执行 HELP ROUTINE LOAD; 查看。

#### 查看任务状态

- 显示 [database] 下，所有的例行导入作业（包括已停止或取消的作业）。结果为一行或多行。

  ```sql
  USE [database];
  SHOW ALL ROUTINE LOAD;
  ```

- 显示 [database] 下，名称为 job_name 的当前正在运行的例行导入作业.

  ```sql
  SHOW ROUTINE LOAD FOR [database.][job_name];
  ```

> 注意： StarRocks 只能查看当前正在运行中的任务，已结束和未开始的任务无法查看。

查看任务状态的具体命令和示例可以通过 `HELP SHOW ROUTINE LOAD;` 命令查看。

查看任务运行状态（包括子任务）的具体命令和示例可以通过 `HELP SHOW ROUTINE LOAD TASK;` 命令查看。

以上述创建的导入任务为示例，以下命令能查看当前正在运行的所有Routine Load任务：

```sql
MySQL [load_test]> SHOW ROUTINE LOAD\G;

*************************** 1. row ***************************

                  Id: 14093
                Name: routine_load_wikipedia
          CreateTime: 2020-05-16 16:00:48
           PauseTime: N/A
             EndTime: N/A
              DbName: default_cluster:load_test
           TableName: routine_wiki_edit
               State: RUNNING
      DataSourceType: KAFKA
      CurrentTaskNum: 1
       JobProperties: {"partitions":"*","columnToColumnExpr":"event_time,channel,user,is_anonymous,is_minor,is_new,is_robot,is_unpatrolled,delta,added,deleted","maxBatchIntervalS":"10","whereExpr":"*","maxBatchSizeBytes":"104857600","columnSeparator":"','","maxErrorNum":"1000","currentTaskConcurrentNum":"1","maxBatchRows":"200000"}
DataSourceProperties: {"topic":"starrocks-load","currentKafkaPartitions":"0","brokerList":"localhost:9092"}
    CustomProperties: {}
           Statistic: {"receivedBytes":150821770,"errorRows":122,"committedTaskNum":12,"loadedRows":2399878,"loadRowsRate":199000,"abortedTaskNum":1,"totalRows":2400000,"unselectedRows":0,"receivedBytesRate":12523000,"taskExecuteTimeMs":12043}
            Progress: {"0":"13634667"}
ReasonOfStateChanged:
        ErrorLogUrls: http://172.26.108.172:9122/api/_load_error_log?file=__shard_53/error_log_insert_stmt_47e8a1d107ed4932-8f1ddf7b01ad2fee_47e8a1d107ed4932_8f1ddf7b01ad2fee, http://172.26.108.172:9122/api/_load_error_log?file=__shard_54/error_log_insert_stmt_e0c0c6b040c044fd-a162b16f6bad53e6_e0c0c6b040c044fd_a162b16f6bad53e6, http://172.26.108.172:9122/api/_load_error_log?file=__shard_55/error_log_insert_stmt_ce4c95f0c72440ef-a442bb300bd743c8_ce4c95f0c72440ef_a442bb300bd743c8
            OtherMsg:
1 row in set (0.00 sec)
```

可以看到示例中创建的名为routine_load_wikipedia的导入任务，其中重要的字段释义：

- State：导入任务状态。RUNNING，表示该导入任务处于持续运行中。
- Statistic为进度信息，记录了从创建任务开始后的导入信息。
- receivedBytes：接收到的数据大小，单位是「Byte」
- errorRows：导入错误行数
- committedTaskNum：FE提交的Task数
- loadedRows：已导入的行数
- loadRowsRate：导入数据速率，单位是「行每秒(row/s)」
- abortedTaskNum：BE失败的Task数
- totalRows：接收的总行数
- unselectedRows：被where条件过滤的行数
- receivedBytesRate：接收数据速率，单位是「Bytes/s」
- taskExecuteTimeMs：导入耗时，单位是「ms」
- ErrorLogUrls：错误信息日志，可以通过URL看到导入过程中的错误信息

#### 暂停导入任务

使用PAUSE语句后，此时导入任务进入PAUSED状态，数据暂停导入，但任务未消亡，可以通过RESUME语句可以重启任务：

- 暂停名称为 job_name 的例行导入任务。

  ```sql
  PAUSE ROUTINE LOAD FOR [job_name];
  ```

可以通过 `HELP PAUSE ROUTINE LOAD;`命令查看帮助和示例。

```sql
MySQL [load_test]> SHOW ROUTINE LOAD\G;
*************************** 1. row ***************************
                  Id: 14093
                Name: routine_load_wikipedia
          CreateTime: 2020-05-16 16:00:48
           PauseTime: 2020-05-16 16:03:39
             EndTime: N/A
              DbName: default_cluster:load_test
           TableName: routine_wiki_edit
               State: PAUSED
      DataSourceType: KAFKA
      CurrentTaskNum: 0
       JobProperties: {"partitions":"*","columnToColumnExpr":"event_time,channel,user,is_anonymous,is_minor,is_new,is_robot,is_unpatrolled,delta,added,deleted","maxBatchIntervalS":"10","whereExpr":"*","maxBatchSizeBytes":"104857600","columnSeparator":"','","maxErrorNum":"1000","currentTaskConcurrentNum":"1","maxBatchRows":"200000"}
DataSourceProperties: {"topic":"starrocks-load","currentKafkaPartitions":"0","brokerList":"localhost:9092"}
    CustomProperties: {}
           Statistic: {"receivedBytes":162767220,"errorRows":132,"committedTaskNum":13,"loadedRows":2589972,"loadRowsRate":115000,"abortedTaskNum":7,"totalRows":2590104,"unselectedRows":0,"receivedBytesRate":7279000,"taskExecuteTimeMs":22359}
            Progress: {"0":"13824771"}
ReasonOfStateChanged: ErrorReason{code=errCode = 100, msg='User root pauses routine load job'}
        ErrorLogUrls: http://172.26.108.172:9122/api/_load_error_log?file=__shard_54/error_log_insert_stmt_e0c0c6b040c044fd-a162b16f6bad53e6_e0c0c6b040c044fd_a162b16f6bad53e6, http://172.26.108.172:9122/api/_load_error_log?file=__shard_55/error_log_insert_stmt_ce4c95f0c72440ef-a442bb300bd743c8_ce4c95f0c72440ef_a442bb300bd743c8, http://172.26.108.172:9122/api/_load_error_log?file=__shard_56/error_log_insert_stmt_8753041cd5fb42d0-b5150367a5175391_8753041cd5fb42d0_b5150367a5175391
            OtherMsg:
1 row in set (0.01 sec)
```

暂停导入任务后，任务的State变更为PAUSED，Statistic和Progress中的导入信息停止更新。此时，任务并未消亡，通过SHOW ROUTINE LOAD语句可以看到已经暂停的导入任务。

#### 恢复导入任务

使用RESUME语句后，任务会短暂的进入 **NEED_SCHEDULE** 状态，表示任务正在重新调度，一段时间后会重新恢复至RUNING状态，继续导入数据。

- 重启名称为 job_name 的例行导入任务。

  ```sql
  RESUME ROUTINE LOAD FOR [job_name];
  ```

可以通过 `HELP RESUME ROUTINE LOAD;` 命令查看帮助和示例。

```sql
MySQL [load_test]> RESUME ROUTINE LOAD FOR routine_load_wikipedia;
Query OK, 0 rows affected (0.01 sec)
MySQL [load_test]> SHOW ROUTINE LOAD\G;
*************************** 1. row ***************************
                  Id: 14093
                Name: routine_load_wikipedia
          CreateTime: 2020-05-16 16:00:48
           PauseTime: N/A
             EndTime: N/A
              DbName: default_cluster:load_test
           TableName: routine_wiki_edit
               State: NEED_SCHEDULE
      DataSourceType: KAFKA
      CurrentTaskNum: 0
       JobProperties: {"partitions":"*","columnToColumnExpr":"event_time,channel,user,is_anonymous,is_minor,is_new,is_robot,is_unpatrolled,delta,added,deleted","maxBatchIntervalS":"10","whereExpr":"*","maxBatchSizeBytes":"104857600","columnSeparator":"','","maxErrorNum":"1000","currentTaskConcurrentNum":"1","maxBatchRows":"200000"}
DataSourceProperties: {"topic":"starrocks-load","currentKafkaPartitions":"0","brokerList":"localhost:9092"}
    CustomProperties: {}
           Statistic: {"receivedBytes":162767220,"errorRows":132,"committedTaskNum":13,"loadedRows":2589972,"loadRowsRate":115000,"abortedTaskNum":7,"totalRows":2590104,"unselectedRows":0,"receivedBytesRate":7279000,"taskExecuteTimeMs":22359}
            Progress: {"0":"13824771"}
ReasonOfStateChanged:
        ErrorLogUrls: http://172.26.108.172:9122/api/_load_error_log?file=__shard_54/error_log_insert_stmt_e0c0c6b040c044fd-a162b16f6bad53e6_e0c0c6b040c044fd_a162b16f6bad53e6, http://172.26.108.172:9122/api/_load_error_log?file=__shard_55/error_log_insert_stmt_ce4c95f0c72440ef-a442bb300bd743c8_ce4c95f0c72440ef_a442bb300bd743c8, http://172.26.108.172:9122/api/_load_error_log?file=__shard_56/error_log_insert_stmt_8753041cd5fb42d0-b5150367a5175391_8753041cd5fb42d0_b5150367a5175391
            OtherMsg:
1 row in set (0.00 sec)
MySQL [load_test]> SHOW ROUTINE LOAD\G;
*************************** 1. row ***************************
                  Id: 14093
                Name: routine_load_wikipedia
          CreateTime: 2020-05-16 16:00:48
           PauseTime: N/A
             EndTime: N/A
              DbName: default_cluster:load_test
           TableName: routine_wiki_edit
               State: RUNNING
      DataSourceType: KAFKA
      CurrentTaskNum: 1
       JobProperties: {"partitions":"*","columnToColumnExpr":"event_time,channel,user,is_anonymous,is_minor,is_new,is_robot,is_unpatrolled,delta,added,deleted","maxBatchIntervalS":"10","whereExpr":"*","maxBatchSizeBytes":"104857600","columnSeparator":"','","maxErrorNum":"1000","currentTaskConcurrentNum":"1","maxBatchRows":"200000"}
DataSourceProperties: {"topic":"starrocks-load","currentKafkaPartitions":"0","brokerList":"localhost:9092"}
    CustomProperties: {}
           Statistic: {"receivedBytes":175337712,"errorRows":142,"committedTaskNum":14,"loadedRows":2789962,"loadRowsRate":118000,"abortedTaskNum":7,"totalRows":2790104,"unselectedRows":0,"receivedBytesRate":7422000,"taskExecuteTimeMs":23623}
            Progress: {"0":"14024771"}
ReasonOfStateChanged:
        ErrorLogUrls: http://172.26.108.172:9122/api/_load_error_log?file=__shard_55/error_log_insert_stmt_ce4c95f0c72440ef-a442bb300bd743c8_ce4c95f0c72440ef_a442bb300bd743c8, http://172.26.108.172:9122/api/_load_error_log?file=__shard_56/error_log_insert_stmt_8753041cd5fb42d0-b5150367a5175391_8753041cd5fb42d0_b5150367a5175391, http://172.26.108.172:9122/api/_load_error_log?file=__shard_57/error_log_insert_stmt_31304c87bb82431a-9f2baf7d5fd7f252_31304c87bb82431a_9f2baf7d5fd7f252
            OtherMsg:
1 row in set (0.00 sec)
ERROR: No query specified
```

重启导入任务后，可以看到第一次查询任务时，State变更为**NEED_SCHEDULE**，表示任务正在重新调度；第二次查询任务时，State变更为**RUNING**，同时Statistic和Progress中的导入信息开始更新，继续导入数据。

#### 停止导入任务

使用STOP语句让导入任务进入STOP状态，数据停止导入，任务消亡，无法恢复数据导入。

- 停止名称为 job_name 的例行导入任务。`

  ```sql
  STOP ROUTINE LOAD FOR [job_name];
  ```

可以通过 `HELP STOP ROUTINE LOAD;` 命令查看帮助和示例。

```sql
MySQL [load_test]> STOP ROUTINE LOAD FOR routine_load_wikipedia;
Query OK, 0 rows affected (0.01 sec)
MySQL [load_test]> SHOW ALL ROUTINE LOAD\G;
*************************** 1. row ***************************
                  Id: 14093
                Name: routine_load_wikipedia
          CreateTime: 2020-05-16 16:00:48
           PauseTime: N/A
             EndTime: 2020-05-16 16:08:25
              DbName: default_cluster:load_test
           TableName: routine_wiki_edit
               State: STOPPED
      DataSourceType: KAFKA
      CurrentTaskNum: 0
       JobProperties: {"partitions":"*","columnToColumnExpr":"event_time,channel,user,is_anonymous,is_minor,is_new,is_robot,is_unpatrolled,delta,added,deleted","maxBatchIntervalS":"10","whereExpr":"*","maxBatchSizeBytes":"104857600","columnSeparator":"','","maxErrorNum":"1000","currentTaskConcurrentNum":"1","maxBatchRows":"200000"}
DataSourceProperties: {"topic":"starrocks-load","currentKafkaPartitions":"0","brokerList":"localhost:9092"}
    CustomProperties: {}
           Statistic: {"receivedBytes":325534440,"errorRows":264,"committedTaskNum":26,"loadedRows":5179944,"loadRowsRate":109000,"abortedTaskNum":18,"totalRows":5180208,"unselectedRows":0,"receivedBytesRate":6900000,"taskExecuteTimeMs":47173}
            Progress: {"0":"16414875"}
ReasonOfStateChanged:
        ErrorLogUrls: http://172.26.108.172:9122/api/_load_error_log?file=__shard_67/error_log_insert_stmt_79e9504cafee4fbd-b3981a65fb158cde_79e9504cafee4fbd_b3981a65fb158cde, http://172.26.108.172:9122/api/_load_error_log?file=__shard_68/error_log_insert_stmt_b6981319ce56421b-bf4486c2cd371353_b6981319ce56421b_bf4486c2cd371353, http://172.26.108.172:9122/api/_load_error_log?file=__shard_69/error_log_insert_stmt_1121400c1f6f4aed-866c381eb49c966e_1121400c1f6f4aed_866c381eb49c966e
            OtherMsg:
```

停止导入任务后，任务的State变更为STOP，Statistic和Progress中的导入信息再也不会更新。此时，通过SHOW ROUTINE LOAD语句无法看到已经停止的导入任务。

### Insert Into loading

#### 导入示例

##### 创建数据库与数据表

```sql
mysql> CREATE DATABASE IF NOT EXISTS load_test;
mysql> USE load_test;
mysql> CREATE TABLE insert_wiki_edit
(
    event_time DATETIME,
    channel VARCHAR(32) DEFAULT '',
    user VARCHAR(128) DEFAULT '',
    is_anonymous TINYINT DEFAULT '0',
    is_minor TINYINT DEFAULT '0',
    is_new TINYINT DEFAULT '0',
    is_robot TINYINT DEFAULT '0',
    is_unpatrolled TINYINT DEFAULT '0',
    delta INT SUM DEFAULT '0',
    added INT SUM DEFAULT '0',
    deleted INT SUM DEFAULT '0'
)
AGGREGATE KEY(event_time, channel, user, is_anonymous, is_minor, is_new, is_robot, is_unpatrolled)
PARTITION BY RANGE(event_time)
(
    PARTITION p06 VALUES LESS THAN ('2015-09-12 06:00:00'),
    PARTITION p12 VALUES LESS THAN ('2015-09-12 12:00:00'),
    PARTITION p18 VALUES LESS THAN ('2015-09-12 18:00:00'),
    PARTITION p24 VALUES LESS THAN ('2015-09-13 00:00:00')
)
DISTRIBUTED BY HASH(user) BUCKETS 10
PROPERTIES("replication_num" = "1");
```

##### 通过values导入数据

```sql
mysql> INSERT INTO insert_wiki_edit VALUES("2015-09-12 00:00:00","#en.wikipedia","GELongstreet",0,0,0,0,0,36,36,0),("2015-09-12 00:00:00","#ca.wikipedia","PereBot",0,1,0,1,0,17,17,0);
Query OK, 2 rows affected (0.29 sec)
{'label':'insert_1f12c916-5ff8-4ba9-8452-6fc37fac2e75', 'status':'VISIBLE', 'txnId':'601'}
```

##### 通过select导入数据

```sql
mysql> INSERT INTO insert_wiki_edit WITH LABEL insert_load_wikipedia SELECT * FROM routine_wiki_edit; 
Query OK, 18203 rows affected (0.40 sec)
{'label':'insert_load_wikipedia', 'status':'VISIBLE', 'txnId':'618'}
```

### flink connector

#### 使用方式

[点击下载插件](https://github.com/StarRocks/flink-connector-starrocks/releases)

[源码地址](https://github.com/StarRocks/flink-connector-starrocks)

将`com.starrocks.table.connector.flink.StarRocksDynamicTableSinkFactory`加入到：`src/main/resources/META-INF/services/org.apache.flink.table.factories.Factory`。

将以下内容加入`pom.xml`:

```xml
<dependency>
    <groupId>com.starrocks</groupId>
    <artifactId>flink-connector-starrocks</artifactId>
    <!-- for flink-1.11, flink-1.12 -->
    <version>1.1.1_flink-1.11</version>
    <!-- for flink-1.13 -->
    <version>1.1.1_flink-1.13</version>
</dependency>
```

使用方式如下：

```scala
// -------- sink with raw json string stream --------
fromElements(new String[]{
    "{\"score\": \"99\", \"name\": \"stephen\"}",
    "{\"score\": \"100\", \"name\": \"lebron\"}"
}).addSink(
    StarRocksSink.sink(
        // the sink options
        StarRocksSinkOptions.builder()
            .withProperty("jdbc-url", "jdbc:mysql://fe1_ip:query_port,fe2_ip:query_port,fe3_ip:query_port?xxxxx")
            .withProperty("load-url", "fe1_ip:http_port;fe2_ip:http_port;fe3_ip:http_port")
            .withProperty("username", "xxx")
            .withProperty("password", "xxx")
            .withProperty("table-name", "xxx")
            .withProperty("database-name", "xxx")
            .withProperty("sink.properties.format", "json")
            .withProperty("sink.properties.strip_outer_array", "true")
            .build()
    )
);


// -------- sink with stream transformation --------
class RowData {
    public int score;
    public String name;
    public RowData(int score, String name) {
        ......
    }
}
fromElements(
    new RowData[]{
        new RowData(99, "stephen"),
        new RowData(100, "lebron")
    }
).addSink(
    StarRocksSink.sink(
        // the table structure
        TableSchema.builder()
            .field("score", DataTypes.INT())
            .field("name", DataTypes.VARCHAR(20))
            .build(),
        // the sink options
        StarRocksSinkOptions.builder()
            .withProperty("jdbc-url", "jdbc:mysql://fe1_ip:query_port,fe2_ip:query_port,fe3_ip:query_port?xxxxx")
            .withProperty("load-url", "fe1_ip:http_port;fe2_ip:http_port;fe3_ip:http_port")
            .withProperty("username", "xxx")
            .withProperty("password", "xxx")
            .withProperty("table-name", "xxx")
            .withProperty("database-name", "xxx")
            .withProperty("sink.properties.column_separator", "\\x01")
            .withProperty("sink.properties.row_delimiter", "\\x02")
            .build(),
        // set the slots with streamRowData
        (slots, streamRowData) -> {
            slots[0] = streamRowData.score;
            slots[1] = streamRowData.name;
        }
    )
);
```

或者：

```scala
// create a table with `structure` and `properties`
// Needed: Add `com.starrocks.connector.flink.table.StarRocksDynamicTableSinkFactory` to: `src/main/resources/META-INF/services/org.apache.flink.table.factories.Factory`
tEnv.executeSql(
    "CREATE TABLE USER_RESULT(" +
        "name VARCHAR," +
        "score BIGINT" +
    ") WITH ( " +
        "'connector' = 'starrocks'," +
        "'jdbc-url'='jdbc:mysql://fe1_ip:query_port,fe2_ip:query_port,fe3_ip:query_port?xxxxx'," +
        "'load-url'='fe1_ip:http_port;fe2_ip:http_port;fe3_ip:http_port'," +
        "'database-name' = 'xxx'," +
        "'table-name' = 'xxx'," +
        "'username' = 'xxx'," +
        "'password' = 'xxx'," +
        "'sink.buffer-flush.max-rows' = '1000000'," +
        "'sink.buffer-flush.max-bytes' = '300000000'," +
        "'sink.buffer-flush.interval-ms' = '5000'," +
        "'sink.properties.column_separator' = '\\x01'," +
        "'sink.properties.row_delimiter' = '\\x02'," +
        "'sink.max-retries' = '3'" +
        "'sink.properties.*' = 'xxx'" + // stream load properties like `'sink.properties.columns' = 'k1, v1'`
    ")"
);
```

其中Sink选项如下：

| Option                        | Required | Default           | Type   | Description                                                  |
| :---------------------------- | :------- | :---------------- | :----- | :----------------------------------------------------------- |
| connector                     | YES      | NONE              | String | **starrocks**                                                |
| jdbc-url                      | YES      | NONE              | String | this will be used to execute queries in starrocks.           |
| load-url                      | YES      | NONE              | String | **fe_ip:http_port;fe_ip:http_port** separated with '**;**', which would be used to do the batch sinking. |
| database-name                 | YES      | NONE              | String | starrocks database name                                      |
| table-name                    | YES      | NONE              | String | starrocks table name                                         |
| username                      | YES      | NONE              | String | starrocks connecting username                                |
| password                      | YES      | NONE              | String | starrocks connecting password                                |
| sink.semantic                 | NO       | **at-least-once** | String | **at-least-once** or **exactly-once**(**flush at checkpoint only** and options like **sink.buffer-flush.\*** won't work either). |
| sink.buffer-flush.max-bytes   | NO       | 94371840(90M)     | String | the max batching size of the serialized data, range: **[64MB, 10GB]**. |
| sink.buffer-flush.max-rows    | NO       | 500000            | String | the max batching rows, range: **[64,000, 5000,000]**.        |
| sink.buffer-flush.interval-ms | NO       | 300000            | String | the flushing time interval, range: **[1000ms, 3600000ms]**.  |
| sink.max-retries              | NO       | 1                 | String | max retry times of the stream load request, range: **[0, 10]**. |
| sink.connect.timeout-ms       | NO       | 1000              | String | Timeout in millisecond for connecting to the `load-url`, range: **[100, 60000]**. |
| sink.properties.*             | NO       | NONE              | String | the stream load properties like **'sink.properties.columns' = 'k1, k2, k3'**. |

#### 注意事项

- 支持exactly-once的数据sink保证，需要外部系统的 two phase commit 机制。由于 StarRocks 无此机制，我们需要依赖flink的checkpoint-interval在每次checkpoint时保存批数据以及其label，在checkpoint完成后的第一次invoke中阻塞flush所有缓存在state当中的数据，以此达到精准一次。但如果StarRocks挂掉了，会导致用户的flink sink stream 算子长时间阻塞，并引起flink的监控报警或强制kill。
- 默认使用csv格式进行导入，用户可以通过指定`'sink.properties.row_delimiter' = '\\x02'`（此参数自 StarRocks-1.15.0 开始支持）与`'sink.properties.column_separator' = '\\x01'`来自定义行分隔符与列分隔符。
- 如果遇到导入停止的 情况，请尝试增加flink任务的内存。

#### 完整示例

- 完整代码工程，参考 [demo](https://github.com/DorisDB/demo)

# 总结

## 联邦查询（外表）

StarRocks 支持以外部表的形式，接入其他数据源。外部表指的是保存在其他数据源中的数据表，而 StartRocks 只保存表对应的元数据，并直接向外部表所在数据源发起查询。目前 StarRocks 已支持的第三方数据源包括 MySQL、HDFS、ElasticSearch、Hive。对这几种种数据源，**现阶段只支持读取，还不支持写入**。

## 物化视图

它一种包含一个查询结果的数据库对象，它可以是远端数据的一份本地拷贝，也可以是一个表或一个 join 结果的行/列的一个子集，还可以是使用聚合函数的一个汇总。相对于普通的逻辑视图，将数据「物化」后，能够带来查询性能的提升。

物化视图的使用场景有：

- 分析需求覆盖明细数据查询以及固定维度聚合查询两方面。
- 需要做对排序键前缀之外的其他列组合形式做范围条件过滤。
- 需要对明细表的任意维度做粗粒度聚合分析。

## bitmap、HLL 去重

### Bitmap实现精确去重

假如给定一个数组A, 其取值范围为[0, n)(注: 不包括n), 对该数组去重, 可采用(n+7)/8的字节长度的bitmap, 初始化为全0; 逐个处理数组A的元素, 以A中元素取值作为bitmap的下标, 将该下标的bit置1; 最后统计bitmap中1的个数即为数组A的count distinct结果.

### 用HLL实现近似去重

**HLL类型**是基于HyperLogLog算法的工程实现。用于保存HyperLogLog计算过程的中间结果，它只能作为数据表的指标列类型。HyperLogLog是一种近似的去重算法，能够使用极少的存储空间计算一个数据集的不重复元素的个数。

### 画像、标签场景功能（数组）

数组，作为数据库的一种扩展类型，在 PG、ClickHouse、Snowflake 等系统中都有相关特性支持，可以广泛的应用于A/B Test对比、用户标签分析、人群画像等场景。StarRocks 当前支持了 多维数组嵌套、数组切片、比较、过滤等特性。

## CBO 优化器

StarRocks推出的新优化器，可以针对复杂 Ad-hoc 场景生成更优的执行计划。StarRocks采用cascades技术框架，实现基于成本（Cost-based Optimizer 后面简称CBO）的查询规划框架，新增了更多的统计信息来完善成本估算，也补充了各种全新的查询转换（Transformation）和实现（Implementation）规则，能够在数万级别查询计划空间中快速找到最优计划。

## 窗口函数

窗口函数是一类特殊的内置函数。和聚合函数类似，窗口函数也是对于多个输入行做计算得到一个数据值。不同的是，窗口函数是在一个特定的窗口内对输入数据做处理，而不是按照group by来分组计算。每个窗口内的数据可以用over()从句进行排序和分组。窗口函数会**对结果集的每一行**计算出一个单独的值，而不是每个group by分组计算一个值。这种灵活的方式允许用户在select从句中增加额外的列，给用户提供了更多的机会来对结果集进行重新组织和过滤。窗口函数只能出现在select列表和最外层的order by从句中。在查询过程中，窗口函数会在最后生效，就是说，在执行完join，where和group by等操作之后再执行。窗口函数在金融和科学计算领域经常被使用到，用来分析趋势、计算离群值以及对大量数据进行分桶分析等。

## Lateral Join

「行列转化」是ETL处理过程中常见的操作，Lateral 一个特殊的Join关键字，能够按照每行和内部的子查询或者table function关联，通过Lateral 与unnest配合，我们可以实现一行转多行的功能。

## 批量导出

数据导出（Export）是 StarRocks 提供的一种将数据导出并存储到其他介质上的功能。该功能可以将用户指定的表或分区的数据，以**文本**的格式，通过 Broker 进程导出到远端存储上，如 HDFS/阿里云OSS/AWS S3（或者兼容S3协议的对象存储） 等。

## 数据导入

### Stream load

StarRocks支持从本地直接导入数据，支持CSV文件格式。数据量在10GB以下。

Stream Load 是一种同步的导入方式，用户通过发送 HTTP 请求将本地文件或数据流导入到 StarRocks 中。Stream Load 同步执行导入并返回导入结果。用户可直接通过请求的返回值判断导入是否成功。

### BrokerLoad

StarRocks支持从Apache HDFS、Amazon S3等外部存储系统导入数据，支持CSV、ORCFile、Parquet等文件格式。数据量在几十GB到上百GB 级别。

在Broker Load模式下，通过部署的Broker程序，StarRocks可读取对应数据源（如HDFS, S3）上的数据，利用自身的计算资源对数据进行预处理和导入。这是一种**异步**的导入方式，用户需要通过MySQL协议创建导入，并通过查看导入命令检查导入结果。

本节主要介绍Broker导入的基本原理、使用示例、最佳实践，及常见问题。

### Routine Load

Routine Load 是一种例行导入方式，StarRocks通过这种方式支持从Kafka持续不断的导入数据，并且支持通过SQL控制导入任务的暂停、重启、停止。本节主要介绍该功能的基本原理和使用方式。

### Spark Load

Spark Load 通过外部的 Spark 资源实现对导入数据的预处理，提高 StarRocks 大数据量的导入性能并且节省 StarRocks 集群的计算资源。主要用于**初次迁移**、**大数据量导入** StarRocks 的场景（数据量可到TB级别）。

Spark Load 是一种**异步**导入方式，用户需要通过 MySQL 协议创建 Spark 类型导入任务，并可以通过 SHOW LOAD 查看导入结果。

### Insert Into loading

Insert Into 语句的使用方式和 MySQL 等数据库中 Insert Into 语句的使用方式类似。 但在 StarRocks 中，所有的数据写入都是 ***一个独立的导入作业\*** ，所以这里将 Insert Into 也作为一种导入方式介绍。

### flink connector

flink的用户想要将数据sink到StarRocks当中，但是flink官方只提供了flink-connector-jdbc, 不足以满足导入性能要求，为此我们新增了一个flink-connector-starrocks，内部实现是通过缓存并批量由stream load导入。

### datax writer

StarRocksWriter 插件实现了写入数据到 StarRocks 的目的表的功能。在底层实现上， StarRocksWriter 通过Stream load以csv或 json 格式导入数据至StarRocks。内部将`reader`读取的数据进行缓存后批量导入至StarRocks，以提高写入性能。总体数据流是 `source -> Reader -> DataX channel -> Writer -> StarRocks`。

## 汇总

| 功能                | 验证通过 | 支撑场景                                                     | 备注                                                         |
| ------------------- | -------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 外部表              | 是       | 联邦查询场景，例如StarRocks的明细表可以关联Mysql的维度表     | 目前支持MySQL、HDFS、ElasticSearch、Hive以及StarRocks这些数据源 |
| bitmap精确去重      | 是       | 精确去重：如果基数在亿级以上，并且需要精确去重的场景         | 在去重场景中，与传统去重方案对比，具有时间和空间上的优势     |
| HLL近似去重         | 是       | 近似去重：如果基数在亿级以上，可以接受近似去重的场景。       | 计算结果的误差可控制在1%—10%左右，误差与数据集大小以及所采用的哈希函数有关。 |
| 数组                | 是       | A/B Test对比、用户标签分析、人群画像等场景                   | 当前支持了 多维数组嵌套、数组切片、比较、过滤等特性。        |
| CBO 优化器          | 是       | 针对复杂 Ad-hoc 场景生成更优的执行计划                       |                                                              |
| 窗口函数            | 是       | 用来分析趋势、计算离群值以及对大量数据进行分桶分析等         |                                                              |
| 批量导出            | 是       | 指定的表和分区以文本格式，通过 Broker 进程导出到远端存储上，如 HDFS/阿里云OSS/AWS S3（或者兼容S3协议的对象存储） |                                                              |
| Lateral Join        | 是       | 行转列场景：一行转多行                                       | 支持String，Array类型，Bitmap类型之间的转化，当前还不支持子查询 |
| Stream load         | 是       | 程序/本地直接导入数据，支持CSV文件格式。数据量在10GB以下。   | 是一种发送 HTTP 请求的同步的导入方式                         |
| BrokerLoad          | 否       | 数据源（如HDFS, S3）上的数据                                 | 离线数据导入                                                 |
| Spark Load          | 否       | 初次迁移、大数据量导入StarRocks                              | 离线数据导入                                                 |
| Routine Load        | 是       | 日志数据和业务数据库的binlog等数据同步到Kafka，导入过程不涉及复杂的多表关联和ETL处理优的场景 | 实时数据导入：支持从Kafka持续不断的导入数据，并且支持通过SQL控制导入任务的暂停、重启、停止 |
| Insert Into loading | 是       | 仅做测试使用场景                                             | 仅导入几条测试数据，验证一下 StarRocks 系统的功能。          |
| Flink-connector     | 是       | 流导入，获取实时变更的数据                                   | 实时数据导入：导入过程中有复杂的多表关联和ETL预处理          |
| Datax-writer        | 否       | 批量导入                                                     | 支持大部分数据源                                             |

