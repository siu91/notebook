# TiSpark 集成

> 采用 Spark 和 TiSpark 独立部署方式配置，Spark 2 已经用 HDP 3.1.5 版本部署完成。



## 部署 TiSpark



### 下载 TiSpark 

```shell
cd /usr/hdp/current/spark2-clent/jars
wget https://github.com/pingcap/tispark/releases/download/v2.4.1/tispark-assembly-2.4.1.jar
```



### 配置 spark-default.conf

```shell
vi ${SPARK_HOME}/conf/spark-default.conf
# tispark
# TiDB 集群中 PD 配置
spark.tispark.pd.addresses dev.ti.db01:2379,dev.ti.db02:2379,dev.ti.db03:2379
spark.sql.extensions org.apache.spark.sql.TiExtensions
```



## 验证

```shell
spark-shell --jars $TISPARK_FOLDER/tispark-${name_with_version}.jar
```

```shell
spark.sql("use titpch")
spark.sql("select count(*) from lineitem").show
```

![image-20210924164914516](./assets/image-20210924164914516.png)

# REF

[TiSpark 用户指南 | PingCAP Docs](https://docs.pingcap.com/zh/tidb/stable/tispark-overview#一个使用范例)

[TiSpark 快速上手 | PingCAP Docs](https://docs.pingcap.com/zh/tidb/stable/get-started-with-tispark#使用范例)



**本页编辑**      **[@gongshiwen](http://192.168.1.23/gongshiwen)** <img src="http://192.168.1.23/uploads/-/system/user/avatar/10/avatar.png?width=100" style="zoom:10%;" /> 