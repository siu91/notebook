## 方案选型-Kafka

在流批一体方案中，主要是通过消息队列进行数据传输。所以MQ选型是关键的一环，目前业界主要MQ有Kafka和Pulsar的选择，本文将详细的对Kafka进行描述。

### 起源

Kafka是最初由Linkedin公司开发，是一个分布式、支持分区的（partition）、多副本的（replica），基于zookeeper协调的分布式消息系统，它的最大的特性就是可以实时的处理大量数据以满足各种需求场景：比如基于hadoop的批处理系统、低延迟的实时系统、storm/Spark流式处理引擎，web/nginx日志、访问日志，消息服务等等，用scala语言编写，Linkedin于2010年贡献给了Apache基金会并成为顶级开源项目。

### 整体架构

![](https://res-static.hc-cdn.cn/fms/img/bc271fd41c0cbb98015f7fd8335aeeda1603779972198)

kafka对外使用topic的概念，生产者往topic里写消息，消费者从topic中读消息。为了做到水平扩展，一个topic实际是由多个partition组成的，遇到瓶颈时，可通过增加partition的数量来进行横向扩容，单个parition内是保证消息有序。每新写一条消息，kafka就是在对应的文件append写，所以性能非常高。broker、topics、partitions的一些元信息用zk来存，监控和路由也都会用到zk。图中有两个topic：topic 0有两个partition，topic 1有一个partition，三副本备份。可以看到consumer gourp 1中的consumer 2没有分到partition处理，这是有可能出现的。

### Kafka基本概念

**Broker**

- Kafka集群中的一台或多台服务器称为Broker。Broker存储Topic的数据。
- 如果某topic有N个partition，集群有N个broker，那么每个broker存储该topic的一个partition。
- 如果某topic有N个partition，集群有(N+M)个broker，那么其中有N个broker存储该topic的一个partition，剩下的M个broker不存储该topic的partition数据。
- 如果某topic有N个partition，集群中broker数目少于N个，那么一个broker存储该topic的一个或多个partition。在实际生产环境中，尽量避免这种情况的发生，这种情况容易导致Kafka集群数据不均衡。

**Topic**

- 发布到Kafka的每条消息都有一个类别，是个逻辑概念。
- 物理上不同Topic的消息分开存储，逻辑上一个Topic的消息虽然保存于一个或多个broker上，但用户只需指定消息的Topic即可生产或消费数据而不必关心数据存于何处

**Partition**

- 物理上的Topic分区，一个Topic可以分为多个Partition，至少有一个Partition。
- 每个Partition中的数据使用多个segment文件存储，每个Partition都是一个有序的队列，不同Partition间的数据是无序的。
- Partition中的每条消息都会被分配一个有序的ID（即offset）。

**Producer**

- 消息和数据的生产者。Producer将消息发布到Kafka的topic中。
- Broker接收到Producer发布的消息后，Broker将该消息追加到当前用于追加数据的segment文件中。
- Producer发送的消息，存储到一个Partition中，Producer也可以指定数据存储的Partition。

**Consumer**

- 消息和数据的消费者。Consumer从Broker中读取数据。
- Consumer可以消费多个topic中的数据。

**Consumer Group**

- 每个消费者都属于一个特定的消费者组。
- 可为每个Consumer指定group name，若不指定group name则属于默认的group。
- 一个Topic可以有多个消费者组，Topic的消息会被复制到所有的消费者组中，但每个消费者组只会把消息发送给该组中的一个消费者。
- 消费者组是Kafka用来实现一个Topic消息的广播和单播的手段。

**Leader**

- 每个Partition有多个副本，其中有且仅有一个作为leader。
- Leader是当前负责数据的读写的Partition。

**Follower**

- Follower跟随Leader，所有写请求都通过Leader路由，数据变更会广播给所有Follower，Follower与Leader保持数据同步。
- 如果Leader失效，则从Follower中选举出一个新的Leader。
- 如果Follower与Leader挂掉、卡住或同步太慢，Leader会把这个Follower从"in sync replicas"

### kafka为什么这么快

- 利用 Partition 实现并行处理

  - Topic 只是一个逻辑的概念。每个 Topic 都包含一个或多个 Partition，不同 Partition 可位于不同节点。

  - 一方面，由于不同 Partition 可位于不同机器，因此可以充分利用集群优势，实现机器间的并行处理。

  - 另一方面，由于 Partition 在物理上对应一个文件夹，即使多个 Partition 位于同一个节点，也可通过配置让同一节点上的不同 Partition 置于不同的磁盘上，从而实现磁盘间的并行处理，充分发挥多磁盘的优势。

- 顺序写磁盘

  - Kafka 中每个分区是一个有序的，不可变的消息序列，新的消息不断追加到 Partition 的末尾，这个就是顺序写。

- 充分利用 Page Cache

  - 引入 Cache 层的目的是为了提高 Linux 操作系统对磁盘访问的性能。Cache 层在内存中缓存了磁盘上的部分数据。
  - 当数据的请求到达时，如果在 Cache 中存在该数据且是最新的，则直接将数据传递给用户程序，免除了对底层磁盘的操作，提高了性能。Cache 层也正是磁盘 IOPS 为什么能突破 200 的主要原因之一。

- 零拷贝技术

  - Kafka 中存在大量的网络数据持久化到磁盘(Producer 到 Broker)和磁盘文件通过网络发送(Broker 到 Consumer)的过程。这一过程的性能直接影响 Kafka 的整体吞吐量。
  - 操作系统的核心是内核，独立于普通的应用程序，可以访问受保护的内存空间，也有访问底层硬件设备的权限。

- 批处理

  - 在很多情况下，系统的瓶颈不是 CPU 或磁盘，而是网络IO。
  - 因此，除了操作系统提供的低级批处理之外，Kafka 的客户端和 Broker 还会在通过网络发送数据之前，在一个批处理中累积多条记录 (包括读和写)。
  - 记录的批处理分摊了网络往返的开销，使用了更大的数据包从而提高了带宽利用率。

- 数据压缩

  - Producer 可将数据压缩后发送给 Broker，从而减少网络传输代价，目前支持的压缩算法有：Snappy、Gzip、LZ4。数据压缩一般都是和批处理配套使用来作为优化手段的。

### 核心场景

- 消息队列
  - 比起大多数的消息系统来说，Kafka有更好的吞吐量，内置的分区，冗余及容错性，这让Kafka成为了一个很好的大规模消息处理应用的解决方案。消息系统一般吞吐量相对较低，但是需要更小的端到端延时，并常常依赖于Kafka提供的强大的持久性保障。在这个领域，Kafka足以媲美传统消息系统，如ActiveMQ或RabbitMQ。

- 行为跟踪
  - Kafka的另一个应用场景是跟踪用户浏览页面、搜索及其他行为，以发布-订阅的模式实时记录到对应的topic里。那么这些结果被订阅者拿到后，就可以做进一步的实时处理，或实时监控，或放到hadoop/离线数据仓库里处理。
- 元信息监控
  - 作为操作记录的监控模块来使用，即汇集记录一些操作信息，可以理解为运维性质的数据监控吧。
- 日志收集
  - 日志收集方面，其实开源产品有很多，包括Scribe、Apache Flume。很多人使用Kafka代替日志聚合（log aggregation）。日志聚合一般来说是从服务器上收集日志文件，然后放到一个集中的位置（文件服务器或HDFS）进行处理。然而Kafka忽略掉文件的细节，将其更清晰地抽象成一个个日志或事件的消息流。这就让Kafka处理过程延迟更低，更容易支持多数据源和分布式数据处理。比起以日志为中心的系统比如Scribe或者Flume来说，Kafka提供同样高效的性能和因为复制导致的更高的耐用性保证，以及更低的端到端延迟。
- 流处理
  - 这个场景可能比较多，也很好理解。保存收集流数据，以提供之后对接的Storm或其他流式计算框架进行处理。很多用户会将那些从原始topic来的数据进行阶段性处理，汇总，扩充或者以其他的方式转换到新的topic下再继续后面的处理。例如一个文章推荐的处理流程，可能是先从RSS数据源中抓取文章的内容，然后将其丢入一个叫做“文章”的topic中；后续操作可能是需要对这个内容进行清理，比如回复正常数据或者删除重复数据，最后再将内容匹配的结果返还给用户。这就在一个独立的topic之外，产生了一系列的实时数据处理的流程。Strom和Samza是非常著名的实现这种类型数据转换的框架。
- 事件源
  - 事件源是一种应用程序设计的方式，该方式的状态转移被记录为按时间顺序排序的记录序列。Kafka可以存储大量的日志数据，这使得它成为一个对这种方式的应用来说绝佳的后台。比如动态汇总（News feed）
- 持久性日志（commit log）
  - Kafka可以为一种外部的持久性日志的分布式系统提供服务。这种日志可以在节点间备份数据，并为故障节点数据回复提供一种重新同步的机制。Kafka中日志压缩功能为这种用法提供了条件。在这种用法中，Kafka类似于Apache BookKeeper项目。

### pulsar VS Kafka

|               | Kafka                          | Pulsar                               |
| ------------- | ------------------------------ | ------------------------------------ |
| 消费模型      | producer-subscription-consumer | producer-topic-subscription-consumer |
| 订阅模型      | 拉                             | 推                                   |
| 消息存储      | 发布订阅                       | 发布订阅，点对点                     |
| 多租户        | 支持                           | 支持                                 |
| 写入性能      | 非常好                         | 非常好                               |
| 消费性能      | 非常好                         | 非常好                               |
| 稳定性        | 分区过多或扩容时，写入性能下降 | 分区较多时，性能稳定                 |
| 支持Topic数量 | 单机超过500+ Topic，负载升高   | 5万topic，性能稳定                   |
| 消息优先级    | 不支持                         | 不支持                               |
| 死信队列      | 不支持                         | 支持                                 |
| 消息TTL       | 支持                           | 支持                                 |
| 可靠性        | 很好                           | 很好                                 |
| 异地复制      | 支持（需要mirror-maker）       | 支持（内置）                         |

### kafka VS pulsar总结

|      | pulsar                                                       | kafka                                                        |
| ---- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 优点 | 1、高吞吐量，低延迟，高靠性，高容错<br>2、计算存储分离，水平扩展不需要重平衡<br>3、支持topic的分区数可达到百万级别 | 1、高吞吐量，低延迟，高靠性，高容错<br/>2、生态较好，大数据使用领域较广 |
| 缺点 | 1、n 层体系结构导致需要更多组件：BookKeeper；<br/>2、运行 bookie 和 Pulsar broker 的机器，必须使用高规格的机器。 | 1、重平衡对生产运行影响较大<br>2、单机partition过多，性能明显下降 <br>3、集群消费分区数目受限 |




#### Ref

[比拼Kafka，大数据分析新秀Pulsar到底好在哪 - 知乎](https://zhuanlan.zhihu.com/p/47388267)

[kafka简介](https://www.jianshu.com/p/674363ecc84a)

[Kafka为什么这么快](https://os.51cto.com/art/202008/623763.htm)

[Kafka系列1：Kafka概况 - 知乎专栏](https://zhuanlan.zhihu.com/p/107900688)

[kafka 官网](https://kafka.apache.org/27/documentation.html#georeplication)

[Pulsar  官网](https://pulsar.apache.org/docs/zh-CN/deploy-bare-metal/)

[Pulsar 集群部署](https://pulsar.apache.org/docs/zh-CN/deploy-bare-metal/)

[pulsar-flink-connector](https://flink.apache.org/2021/01/07/pulsar-flink-connector-270.html)

[TICDC sink-uri -配置](https://docs.pingcap.com/zh/tidb/stable/manage-ticdc#sink-uri-%E9%85%8D%E7%BD%AE-pulsar)

[[架构师的选择，Pulsar还是Kafka？](https://www.cnblogs.com/StreamNative/p/14323559.html)](https://www.cnblogs.com/StreamNative/p/14323559.html)