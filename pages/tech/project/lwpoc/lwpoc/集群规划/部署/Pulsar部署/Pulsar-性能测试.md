# Pulsar性能测试文档
## 代码准备

从[GitHub 上](https://github.com/)的[`openmessaging`](https://github.com/openmessaging)克隆：

```
$ git clone https://github.com/openmessaging/openmessaging-benchmark
$ cd openmessaging-benchmark
```

您还需要安装[Maven](https://maven.apache.org/install.html)。

## 创建本地模块

在本地克隆 repo 后，您可以使用单个 Maven 命令创建运行基准测试所需的所有模块：

```
$ mvn install
```

成功通过 SSH 连接到客户端主机后，您可以通过在运行可执行文件时为该工作负载指定 YAML 文件来运行任何[现有的基准测试工作](http://openmessaging.cloud/docs/benchmarks/#benchmarking-workloads)负载`benchmark`。所有工作负载都在该`workloads`文件夹中。下面是一个例子：

```
$ sudo bin/benchmark \
  --drivers driver-pulsar/pulsar.yaml \
  workloads/1-topic-16-partitions-1kb.yaml
```

尽管基准测试是*从*特定客户端主机运行的，但基准测试是在分布式模式下跨多个客户端主机运行的。

有多种 Pulsar“模式”可以运行基准测试。每种模式在`driver-pulsar`文件夹中都有自己的 YAML 配置文件。

| 模式     | 描述                                            | 配置文件                       |
| :------- | :---------------------------------------------- | :----------------------------- |
| 标准     | 禁用消息重复数据删除的 Pulsar（至少一次语义）   | `pulsar.yaml`                  |
| 有效一次 | 启用消息重复数据删除的 Pulsar（“有效一次”语义） | `pulsar-effectively-once.yaml` |

该示例使用了 中配置的“标准”模式`driver-pulsar/pulsar.yaml`。以下是在一次有效模式下运行基准测试工作负载的示例：

```
$ sudo bin/benchmark \
  --drivers driver-pulsar/pulsar-effectively-once.yaml \
  workloads/1-topic-16-partitions-1kb.yaml
```

OpenMessaging 基准测试套件将结果存储在`/opt/benchmark`运行基准测试的客户端主机上的文件夹中的 JSON 文件中。

## 结果解释

最初，应该会看到这样的日志消息，确认正在启动预热阶段：

```
22:03:19.125 [main] INFO - ----- Starting warm-up traffic ------
```

然后，您应该会看到一些读数，然后是如下所示的聚合消息：

```
22:04:19.329 [main] INFO - ----- Aggregated Pub Latency (ms) avg:  2.1 - 50%:  1.7 - 95%:  3.0 - 99%: 11.8 - 99.9%: 45.4 - 99.99%: 52.6 - Max: 55.4
```

此时，基准测试流量将开始。您将开始看到每隔几秒钟发出这样的读数：

```
22:03:29.199 [main] INFO - Pub rate 50175.1 msg/s /  4.8 Mb/s | Cons rate 50175.2 msg/s /  4.8 Mb/s | Backlog:  0.0 K | Pub Latency (ms) avg:  3.5 - 50%:  1.9 - 99%: 39.8 - 99.9%: 52.3 - Max: 55.4
```

下表细分了基准测试日志消息中显示的信息（所有数字均针对最近的 10 秒时间窗口）：

| 名称                   | 意义                   | 单位                                                         |
| :--------------------- | :--------------------- | :----------------------------------------------------------- |
| `Pub rate`             | 消息发布到主题的速率   | 每秒消息数/每秒兆字节数                                      |
| `Cons rate`            | 从主题消耗消息的速率   | 每秒消息数/每秒兆字节数                                      |
| `Backlog`              | 消息系统积压中的消息数 | 消息数（以千计）                                             |
| `Pub latency (ms) avg` | 时间范围内的发布延迟   | 毫秒（平均值、第 50 个百分位数、第 99 个百分位数和第 99.9 个百分位数以及最大值） |

在每个[工作负载](http://openmessaging.cloud/docs/benchmarks/#benchmarking-workloads)结束时，您将看到汇总结果的日志消息：

```
22:19:20.577 [main] INFO - ----- Aggregated Pub Latency (ms) avg:  1.8 - 50%:  1.7 - 95%:  2.8 - 99%:  3.0 - 99.9%:  8.0 - 99.99%: 17.1 - Max: 58.9
```

您还会看到一条这样的消息，它告诉我们基准测试结果已保存到哪个 JSON 文件中（所有 JSON 结果都保存到`/opt/benchmark`目录中）：

```
22:19:20.592 [main] INFO - Writing test result into 1-topic-1-partition-100b-Kafka-2018-01-29-22-19-20.json
```

 [JSON样例](./assets/1-topic-1-partition-100b-Kafka-2018-01-29-22-19-20.json) 