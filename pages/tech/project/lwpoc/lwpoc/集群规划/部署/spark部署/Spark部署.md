### Spark部署文档

#### 环境要求 

| 项目     | 软件        | 版本                  |
| -------- | ----------- | --------------------- |
| 操作系统 | CentOS      | 7.3 及以上的 7.x 版本 |
| 容器环境 | YARN        | 2.4.1                 |
| 基础环境 | Java        | 1.8.x                 |
| 基础环境 | Hadoop/HDFS | 3.1.1                 |

### 安装部署

##### 准备Spark安装包

拷贝spark-3.1.2-bin-hadoop3.2.tgz到环境安装目录，如果支持外网可通过以下连接直接下载

```shell
https://downloads.apache.org/spark/spark-3.1.2/spark-3.1.2-bin-hadoop3.2.tgz
```

下载完成后，解压并`进入`到解压后的目录:

```shell
$ tar xvzf spark-3.1.2-bin-hadoop3.2.tgz
$ cd spark-3.1.2-bin-hadoop3.2
```

在`conf/spark-env.sh.template`修改为`spark-env.sh`并且将`HADOOP_CONF_DIR`指向将Spark指向Hadoop配置文件，`YARN_CONF_DIR`将Spark指向YARN/配置文件

```
export JAVA_HOME=/usr/local/jdk1.8.0_191 #jdk绝对路径
HADOOP_CONF_DIR=/etc/hadoop/conf #hadoop绝对路径
YARN_CONF_DIR=/etc/hadoop/conf #hadoop绝对路径
```



以`cluster`模式启动 Spark 应用程序：

```shell
$ ./bin/spark-submit --class path.to.your.Class --master yarn --deploy-mode cluster [options] <app jar> [app options]
```

例如：

```shell
$ ./bin/spark-submit --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --deploy-mode cluster \
    --driver-memory 4g \
    --executor-memory 2g \
    --executor-cores 1 \
    --queue thequeue \
    examples/jars/spark-examples*.jar \
    10
```

以上启动了一个 YARN 客户端程序，该程序启动了默认的 Application Master。然后 SparkPi 将作为 Application Master 的子线程运行。客户端将定期轮询 Application Master 以获取状态更新并将其显示在控制台中。一旦您的应用程序完成运行，客户端将退出。有关如何查看驱动程序和执行程序日志的信息，请参阅下面的[调试您的应用程序](http://spark.apache.org/docs/latest/running-on-yarn.html#debugging-your-application)部分。

要以`client`模式启动 Spark 应用程序，请执行相同操作，但替换`cluster`为`client`. 下面显示了如何`spark-shell`在`client`模式下运行：

```shell
$ ./bin/spark-shell --master yarn --deploy-mode client
```

#### 添加其他 JAR

在`cluster`模式下，驱动程序在与客户端不同的机器上运行，因此`SparkContext.addJar`无法使用客户端本地的文件开箱即用。要使客户端上的文件可用于`SparkContext.addJar`，请将它们包含`--jars`在启动命令中的选项中。

```shell
$ ./bin/spark-submit --class my.main.Class \
    --master yarn \
    --deploy-mode cluster \
    --jars my-other-jar.jar,my-other-other-jar.jar \
    my-main-jar.jar \
    app_arg1 app_arg2
```

#### 配置

`bin/spark-submit`还将从 中读取配置选项`conf/spark-defaults.conf`，其中每一行由一个键和一个由空格分隔的值组成。例如：

```shell
spark.master            spark://5.6.7.8:7077
spark.executor.memory   4g
spark.eventLog.enabled  true
spark.serializer        org.apache.spark.serializer.KryoSerializer
```

| 名称                       | 默认                                        | 含义                                                         | 发行版本 |
| -------------------------- | ------------------------------------------- | ------------------------------------------------------------ | -------- |
| spark.app.name             |                                             | 应用程序的名称。这将出现在 UI 和日志数据中。                 | 0.9.0    |
| spark.driver.cores         | 1                                           | 用于驱动程序进程的核心数，仅在集群模式下。                   | 1.3.0    |
| spark.driver.maxResultSize | 1G                                          | 每个 Spark 操作（例如收集）的所有分区的序列化结果的总大小限制（以字节为单位）。应至少为 1M，或 0 表示无限制。如果总大小超过此限制，作业将被中止。上限可能会导致驱动程序内存不足错误（取决于 spark.driver.memory 和 JVM 中对象的内存开销）。设置适当的限制可以保护驱动程序免受内存不足错误的影响。 | 1.2.0    |
| spark.driver.memory        | 1G                                          | 用于驱动程序进程的内存量，即 SparkContext 被初始化的地方，格式与 JVM 内存字符串相同，带有大小单位后缀（“k”、“m”、“g”或“t”）（例如`512m`，`2g`） .<br/>*注意：*在客户端模式下，此配置不能`SparkConf` 直接在您的应用程序中设置，因为驱动程序 JVM 已在此时启动。相反，请通过`--driver-memory`命令行选项或在您的默认属性文件中进行设置。 | 1.1.1    |
| spark.executor.memory      | 1克                                         | 每个执行程序进程使用的内存量，格式与 JVM 内存字符串相同，带有大小单位后缀（“k”、“m”、“g”或“t”）（例如`512m`，`2g`）。 | 0.7.0    |
| spark.submit.deployMode    |                                             | Spark驱动程序的部署模式，可以是“client”或“cluster”，即在集群内部的节点之一上本地（“client”）或远程（“cluster”）启动驱动程序。 | 1.5.0    |
| spark.driver.log.layout    | %d{yy/MM/dd HH:mm:ss.SSS} %t %p %c{1}: %m%n | 同步到 的驱动程序日志的布局`spark.driver.log.dfsDir`。如果没有配置，它使用 log4j.properties 中定义的第一个 appender 的布局。如果也没有配置，驱动程序日志使用默认布局。 | 3.0.0    |

有关这些的更多信息，请参阅[配置页面](http://spark.apache.org/docs/latest/configuration.html)。

#### REF

[yarn部署](http://spark.apache.org/docs/latest/running-on-yarn.html)
[配置](http://spark.apache.org/docs/latest/configuration.html)