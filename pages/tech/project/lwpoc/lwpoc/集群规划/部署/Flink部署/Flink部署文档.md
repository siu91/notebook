# FLink部署文档

## 1. 环境要求 

| 项目     | 软件   | 版本                  |
| -------- | ------ | --------------------- |
| 操作系统 | CentOS | 7.3 及以上的 7.x 版本 |
| 容器环境 | YARN   | 2.4.1                 |
| 基础环境 | Java   | 1.8.x                 |
| 基础工具 | ssh    | -                     |



## 2. 安装部署

1、准备flink安装包

 拷贝 [**flink-1.12.5-bin-scala_2.12.tgz**](https://dlcdn.apache.org/flink/flink-1.12.5/flink-1.12.5-bin-scala_2.12.tgz)安装包到hadoop集群构建的目录

2、运行install-flink.sh脚本

```bash
mkdir /deploy/flink/
tar -xvf  flink-1.12.5-bin-scala_2.12.tgz -C /deploy/flink/
```

3、运行验证实例

```bash
# 进入flink目录
cd /deploy/flink/flink-1.12.5
# 运行测试实例
export HADOOP_CLASSPATH=`hadoop classpath`
./bin/flink run -m yarn-cluster ./examples/streaming/TopSpeedWindowing.jar
```

运行结果如下：

![1629787008600](./assets/1629787008600.png)

4、关闭测试集群

```bash
# application_XXXXX_XXX 为步骤3打印的ID值
echo "stop" | ./bin/yarn-session.sh -id application_XXXXX_XXX
```



## 3. 部署flink-gateway

1. 准备flink-gateway安装包https://github.com/ververica/flink-sql-gateway/archive/refs/tags/flink-1.12.0.tar.gz
2. 解压flink-gateway。

```
tar -xvf flink-1.12.0.tar.gz
```

3. 配置flink-home

```
export FLINK_HOME=/deploy/flink/flink-1.12.5
```





## 4. TPC-DS测试

[TPC-DS测试git]: https://github.com/ververica/flink-sql-benchmark

### TPC-DS benchmark

#### Generate test hive dataset

- Step 1: Prepare your environment

  Make sure you have Hadoop and Hive installed in your cluster. `gcc` is also needed to build the TPC-DS data generator.

- Step 2: Build the data generator

  `cd hive-tpcds-setup`

  Run `./tpcds-build.sh`

  Download and build the TPC-DS data generator.

- Step 3: Generate TPC-DS dataset

  `cd hive-tpcds-setup`

  Run `./tpcds-setup.sh 10000`. The hive database is `tpcds_bin_orc_10000`.

  Run `./tpcds-setup.sh <SCALE_FACTOR>` to generate dataset. The "scale factor" represents how much data you will generate, which roughly translates to gigabytes. For example, `./tpcds-setup.sh 10` will generate about 10GB data. Note that the scale factor must be **greater than 1**.

  `tpcds-setup.sh` will launch a MapReduce job to generate the data in text format. By default, the generated data will be placed in `/tmp/tpcds-generate/<SCALE_FACTOR>` of your HDFS cluster. If the folder already exists, the MapReduce job will be skipped.

  Once data generation is completed, `tpcds-setup.sh` will load the data into Hive tables. Make sure the `hive` executable is in your `PATH`, alternatively, you can specify your Hive executable path via `HIVE_BIN` environment variable.

  `tpcds-setup.sh` will create external Hive tables based on the generated text files. These tables reside in a database named `tpcds_text_<SCALE_FACTOR>`. Then `tpcds-setup.sh` will convert the text tables into an optimized format and the converted tables are placed in database `tpcds_bin_<FORMAT>_<SCALE_FACTOR>`. By default, the optimized format is `orc`. You can choose a different format by setting the `FORMAT` environment variable. The following is an example that creates 1TB test dataset in parquet format:

  `FORMAT=parquet HIVE_BIN=/path/to/hive ./tpcds-setup.sh 1000`

  Once the data is loaded into Hive, you can use database `tpcds_bin_<FORMAT>_<SCALE_FACTOR>`to run the benchmark.

#### Run benchmark in flink

- Step 1: Prepare your flink environment.
  - Prepare flink-conf.yaml: [Recommended Conf](https://github.com/ververica/flink-sql-benchmark/blob/master/flink-tpcds/flink-conf.yaml).
  - Setup hive integration: [Hive dependencies](https://ci.apache.org/projects/flink/flink-docs-master/dev/table/hive/#dependencies).
  - Setup hadoop integration: [Hadoop environment](https://ci.apache.org/projects/flink/flink-docs-release-1.9/ops/deployment/hadoop.html).
  - Setup flink cluster: [Standalone cluster](https://ci.apache.org/projects/flink/flink-docs-master/ops/deployment/cluster_setup.html) or [Yarn session](https://ci.apache.org/projects/flink/flink-docs-master/ops/deployment/yarn_setup.html#flink-yarn-session).
  - Recommended environment for 10T
    - 20 machines.
    - Machine: 64 processors. 256GB memory. 1 SSD disk for spill. Multi SATA disks for HDFS.
- Step 2: Build test jar.
  - Modify flink version and hive version of `pom.xml`.
  - `mvn clean install`
- Step 3: Run
  - `flink_home/bin/flink run -c com.ververica.flink.benchmark.Benchmark ./flink-tpcds-0.1-SNAPSHOT-jar-with-dependencies.jar --database tpcds_bin_orc_10000 --hive_conf hive_home/conf`
  - optional `--location`: sql queries path, default using queries in jar.
  - optional `--queries`: sql query names. If the value is 'all', all queries will be executed. eg: 'q1.sql'.
  - optional `--iterations`: The number of iterations that will be run per case, default is 1.
  - optional `--parallelism`: The parallelism, default is 800.



