# LW-POC 技术架构

![image-20210922113442154](pages/架构/assets/arch-技术架构V4.drawio.svg)



- 四个场景
  - 数据汇聚
    - CDC
    - 批流一体（Flink SQL + UDF），入湖入仓
    - 异构数据海量存储
    - ~~治理系统数据、标化系统维表数据~~
    - ~~hive metadata（调度监控、资源监控的场景）~~
  - 数据服务
    - 接口点查
    - ~~事务型交易~~
    - 数据导入/导出
  - 数据分析
    - 数仓多维分析、关联分析（MPP/TiFlash）
    - 湖仓数据关联分析（TiSpark/Spark）
    - Ad-hoc ，大数据交互查询（Trino+Iceberg，MPP/TiFlash）
    - 跨源级联查询（Trino）
  - 数据共享交换
    - 湖仓数据交换（TiSpark/Spark）
    - ~~跨域的数据交换（ADS，TiBinlog）~~
    - ~~跨域的数据发布/订阅（ADS，TiCDC+MQ+多租户）~~
- 三层架构
  - 业务层
    - CDC + MQ + 批流一体（Flink SQL/UDF），实时处理入湖入仓
    - 标准服务接入方式 SQL/JDBC，可负载交易系统
    - 提供数据服务、数据分析、数据共享交换标准的接口/服务
  - 实时数仓
    - 分析和点查（HTAP）
    - HTAP 负载隔离，按需扩展
    - PB 级数据负载能力
    - 数据权限/访问控制（RBAC）
  - 数据湖
    - 统一存储、异构海量存储（结构/半结构/非结构化数据）
    - ~~具备湖仓一体的能力~~
- 主要技术栈：
  - 存储：HDFS、TiKV/TiFlash(RocksDB)
  - 计算：Flink、Spark、MR/Tez
    - SQL/MPP 引擎：Trino
  - 其它：
    - iceberg（表格式）、Ranger（权限）、ShardingSphere（脱敏加密）
- 降本方案
  - ~~AIT（all-in-tidb，or in NewSQL）~~
  - ~~AISR （all-in-starrocks）~~



**本页编辑**      **[@gongshiwen](http://192.168.1.23/gongshiwen)** <img src="http://192.168.1.23/uploads/-/system/user/avatar/10/avatar.png?width=100" style="zoom:10%;" /> 