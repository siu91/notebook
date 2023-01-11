# 方案选型-Flink

> 在构建实时湖仓方案中，批量数据与CDC的流式数据入湖是其中关键一环。业界最主流的批流框架为flink，本文将详细的对flink进行描述。

## 1. Flink

### 1.1 基本架构

![](https://ci.apache.org/projects/flink/flink-docs-release-1.13/fig/processes.svg)

flink是一个基于Master-Slave风格的架构。核心的组件有JobManger 和TaskManager。

- **JobManager** 主要包含一下子组件：
  - **ResourceManager**：
    - 资源提供、回收、分配，管理 task slots。
    - 有YARN、Mesos、Kubernetes 和 standalone 部署多种实现。
    - standalone 只能分配可用的，不能启动新的。
  - **Dispatcher**： 提供REST接口。提供JobMaster，提供WebUI。
  - **JobMaster**：管理单个[JobGraph](https://nightlies.apache.org/flink/flink-docs-release-1.13/zh/docs/concepts/glossary/#logical-graph)的执行。
-  **TaskManager**： 负责执行任务，执行状态汇报。

工作模式：

|                  | Session 模式                                                 | Job 模式                           | Application 模式                    |
| ---------------- | ------------------------------------------------------------ | ---------------------------------- | ----------------------------------- |
| **生命周期**     | 预设的、长期运行的、不受作业影响                             | 提交作业时启动，完成即销毁         | 仅从 Flink 应用程序main方法执行作业 |
| **资源隔离**     | 不隔离，存在资源竞争<br>TaskManager奔溃任务全失败            | 资源隔离，仅影响单作业             | 作用于单应用程序资源隔离            |
| **其他注意事项** | 1.可以节省资源申请和启动时间<br> 2. 适合执行时间短的交互式分析。 | 适合长时间运行且启动时间不敏感任务 | 可看做是客户端运行方案              |

### 1.2  flink特性

- **擅长处理无界和有界数据集**
  - **支持高吞吐、低延迟、高性能的流处理**
  - **支持程序自动优化**：避免特定情况下 Shuffle、排序等昂贵操作，中间结果进行缓存
  - **支持具有 Backpressure 功能的持续流模型**：防止生成数据的速度比下游算子消费的的速度快引发的消息拥堵问题
- **精确的状态控制**：
  - **支持多种状态类型**：支持基础类型、list、map等。
  - **插件化的State Backend**：支持多种状态存储的后端，可存储到内存或数据库中。
  - **精确一次语义(Exactly-once)**： checkpoint 和故障恢复算法保证了故障发生后应用状态的一致性，发生故障时对程序透明。发生故障时，对应用程序透明，不造成正确性的影响
  - **超大数据量状态**： 能够利用其异步以及增量式的 checkpoint 算法，存储数 TB 级别的应用状态
  - **可弹性伸缩的应用**：支持有状态应用的分布式的横向伸缩
- **提供丰富的时间语义支持**
  - **事件时间模式**：根据事件本身自带的时间戳进行结果的计算，事件时间模式的处理总能保证结果的准确性和一致性
  - **Watermark 支持**： 引入了 watermark 的概念，用以衡量事件时间进展。Watermark 也是一种平衡处理延时和完整性的灵活机制。
  - **迟到数据处理**：当以带有 watermark 的事件时间模式处理数据流时，在计算完成之后仍会有相关数据到达。这样的事件被称为迟到事件。
  - **处理时间模式**：根据处理引擎的机器时钟触发计算，一般适用于有着严格的低延迟需求，并且能够容忍近似结果的流处理应用
- **部署应用到任意地方**：
  - **集成多种集群管理服务**：支持 yarn、k8s、Mesos等
  - **便利升级应用服务版本**：在新版本更新升级时，可以根据上一个版本程序记录的 Savepoint 内的服务状态信息来重启服务
  - **方便的集群迁移**：通过使用 Savepoint，流服务应用可以自由的在不同集群中迁移部署
- **良好的监控和控制服务**：
  - **Web UI方式支撑运维**：提供了一个web UI来观察、监视和调试正在运行的应用服务
  - **指标服务**：提供了一个复杂的度量系统来收集和报告系统和用户定义的度量指标信息。度量信息可以导出到多个报表组件服务
  - **标准的WEB REST API接口服务**：提供多种REST API接口，有提交新应用程序、获取正在运行的应用程序的Savepoint服务信息、取消应用服务等接口

### 1.3 与其他框架对比

|                | Flink                                                        | SparkStreaming                                               | ~~Storm~~                                                    |
| -------------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 架构           | 架构介于spark和 storm之间,主从结构 与spark streaming相 似,DataFlow Grpah 与Storm相似,数据流 可以被表示为一个有向 图。每个顶点是一个 用户定义的运算,每向 边表示数据的流动。【Native】 | 架构依赖spark, 主从 模式,每个Batch处理 都依赖主(driver) , 可以理解为时间维度上 的spark DAG。【Micro-Batch】 | 主从模式，且依赖ZK，处理过程中对主的依赖不大。【Native】     |
| 开源协议       | Apache-2.0 License                                           | Apache-2.0 License                                           | Apache-2.0 License                                           |
| 文档           | 规范、详细                                                   | 规范、详细                                                   | 规范、详细                                                   |
| 容错           | 基于Chandy- Lamport distributed snapshots checkpoint机制【Medium】 | WAL及RDD血统机制【High】                                     | Records ACK 【Medium】                                       |
| 处理模型与延迟 | 单条事件处理【亚秒级低延迟】                                 | 一个事件窗☐内的所有 事件。【秒级高延迟】                     | 每次传入的一个事件【亚秒级低延迟】                           |
| 吞吐量         | High                                                         | High                                                         | Low                                                          |
| 数据处理保证   | exactly once【High】                                         | exactly once (实现采 用Chandy-Lamport 算法,即marker- checkpoint ) 【High】 | at least once(实现采 用record-level acknowledgments), Trident可以支持 storm 提供exactly once语义。 【Medium】 |
| 高级API        | Flink栈中提供了提供 了很多具有高级 API 和满足不同场景的类 库:机器学习、图分 析、关系式数据处理【High】 | 能够很容易的对接 Spark生态栈里面的组 件,同时能够对接主流 的消息传输组件及存储 系统。【 High】 | 应用 特定的 storm定义的规则编 写。【Low】                    |
| 易用性         | 支持SQL Steaming, Batch和STREAMING 采用统一编程框架【High】  | 支持SQL Steaming Batch和STREAMING 采用统一编程框架【High】   | 不支持SQL Steaming【Low】                                    |
| 成熟性         | 项目已发展了一段时间，已有较多应用案例【High】               | 已发展了一段时间【High】                                     | 相对较早系统比较稳定【High】                                 |
| 社区活跃度     | Contributors 913                                             | Contributors 1700                                            | Contributors 342                                             |
| star数         | 16.8k                                                        | 30.5k                                                        | 6.3k                                                         |
| 部署性         | 简单                                                         | 简单                                                         | 中（依赖ZK）                                                 |



### 1.4 应用场景

#### 1.4.1 事件驱动型应用

![](https://flink.apache.org/img/usecases-eventdrivenapps.png)

​	事件驱动型应用是一类具有状态的应用，它从一个或多个事件流提取数据，并根据到来的事件触发计算、状态更新或其他外部动作。

   事件驱动型应用无须查询远程数据库，本地数据访问使得它具有更高的吞吐和更低的延迟。而由于定期向远程持久化存储的 checkpoint 工作可以异步、增量式完成，因此对于正常事件处理的影响甚微

​	该特性可用于一下场景：

- 数据异常检测

- 基于规则的报警

- 数据流程监控


#### 1.4.2 数据分析应用

![](https://flink.apache.org/img/usecases-analytics.png)

数据分析任务需要从原始数据中提取有价值的信息和指标。通过flink可以同时支持流式及批量分析。

- 和批量分析相比，由于流式分析省掉了周期性的数据导入和查询过程，因此从事件中获取指标的延迟更低。

- 另一方面，流式分析会简化应用抽象。涵盖了从数据接入到连续结果计算的所有步骤

该特性可用于一下场景：

- 电信网络质量监控

- 移动应用中的产品更新及实验评估分析

- 消费者技术中的实时数据即席分析

- 大规模图分析


#### 1.4.3 数据管道应用

![](https://flink.apache.org/img/usecases-datapipelines.png)

和周期性 ETL 作业相比，持续数据管道可以明显降低将数据移动到目的端的延迟。并且能够做到能够持续消费和发送数据。

#### 1.4.4 行业应用

- **阿里**：双十一运营数据实时计算，40 亿条 / 秒数据。

- **字节跳动**:  基于 Flink 的 MQ-Hive 实时数据集成 
- **腾讯**：
  - 王者荣耀背后的实时大数据平台
  - 腾讯基于flink实时数仓及多维数据分析
- **快手**：统计监控，数据ETL，实时业务处理。
- **滴滴**：
  - 实时监控：业务指标、导航等
  - 实时特征：乘客特征，上下车特征
- **网易**：
  - 网易游戏基于Flink的流行ETL建设
  - 网易云音乐基于Flink+Kafka实时数仓
  - 网易基于Flink+Iceberg构建数据湖

#### 1.4.5  数据仓库中的综合应用

![](assets/flink数据湖应用.svg)

Flink在数据仓库中应用：

1. 作为数据管道：应用在数据入湖、数据湖转换为DWD、DWD转ADS层。（当前核心场景）
   - 节点1：业务数据从kafka通过flink处理后，进入数据湖iceberg中。
   - 节点2：抓取iceberg的增量数据，连接iceberg的维表进行运算，生成中间层数据入到TiDB；
   - 节点3:  TiDB将增量数据CDC抽取到kafka中，flink对增量数据连接TiDB中的维表进行运算，生成服务层数据入到TiDB中。
2. 数据结构变更：业务数据中收到表结构变更事件，触发ICEBERG的schema变更。
3. 数据流监控：对数据流程进行监控，以及基于规则的报警。
5. 数据大屏展示：实时大屏展示数据报表的生成

### 1.5 Flink使用方式

![img](https://flink.apache.org/img/api-stack.png)

flink支持三种不同的调用方式：

1. **ProcessFunction**：提供最细粒度的操作能力，开发者可以任意修复状态，注册定时器及触发器等。
2. **DataStream API**：提供了流处理操作方法，包含了窗口、map、reduce等。
3. **SQL**： 提供了 sql-client客户端，通过sql的方式来提供数据的查询及处理操作。

同时flink官方还实现了以下连接器：

- **Kafka**
- **Upsert Kafka**
- **JDBC**
- **Elasticsearch**
- **FileSystem**
- **HBase** 
- **Hive**


### 1.6 选择Flink的公司

![1628146419585](assets/1628146419585.png)



## 附录：

#### 1. TaskManager 内存

<img src="https://ci.apache.org/projects/flink/flink-docs-release-1.13/fig/detailed-mem-model.svg" style="zoom:30%;" width="1000"/>

| **组成部分**                                                 | **配置参数**                                                 | **描述**                                                     |
| :----------------------------------------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| [框架堆内存（Framework Heap Memory）](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup_tm/#framework-memory) | [`taskmanager.memory.framework.heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-framework-heap-size) | 用于 Flink 框架的 JVM 堆内存（进阶配置）。                   |
| [任务堆内存（Task Heap Memory）](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup_tm/#task-operator-heap-memory) | [`taskmanager.memory.task.heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-task-heap-size) | 用于 Flink 应用的算子及用户代码的 JVM 堆内存。大约占处理内存的40% |
| [托管内存（Managed memory）](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup_tm/#managed-memory) | [`taskmanager.memory.managed.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-managed-size) [`taskmanager.memory.managed.fraction`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-managed-fraction) | 由 Flink 管理的用于排序、哈希表、缓存中间结果及 RocksDB State Backend 的本地内存。大约占处理内存40% |
| [框架堆外内存（Framework Off-heap Memory）](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup_tm/#framework-memory) | [`taskmanager.memory.framework.off-heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-framework-off-heap-size) | 用于 Flink 框架的[堆外内存（直接内存或本地内存）](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup_tm/#configure-off-heap-memory-direct-or-native)（进阶配置）。 |
| [任务堆外内存（Task Off-heap Memory）](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup_tm/#configure-off-heap-memory-direct-or-native) | [`taskmanager.memory.task.off-heap.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-task-off-heap-size) | 用于 Flink 应用的算子及用户代码的[堆外内存（直接内存或本地内存）](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup_tm/#configure-off-heap-memory-direct-or-native)。 |
| 网络内存（Network Memory）                                   | [`taskmanager.memory.network.min`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-network-min) [`taskmanager.memory.network.max`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-network-max) [`taskmanager.memory.network.fraction`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-network-fraction) | 用于任务之间数据传输的直接内存（例如网络传输缓冲）。该内存部分为基于 [Flink 总内存](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup/#configure-total-memory)的[受限的等比内存部分](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup/#capped-fractionated-components)。约占处理内存10% |
| [JVM Metaspace](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup/#jvm-parameters) | [`taskmanager.memory.jvm-metaspace.size`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-jvm-metaspace-size) | Flink JVM 进程的 Metaspace。                                 |
| JVM 开销                                                     | [`taskmanager.memory.jvm-overhead.min`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-jvm-overhead-min) [`taskmanager.memory.jvm-overhead.max`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-jvm-overhead-max) [`taskmanager.memory.jvm-overhead.fraction`](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/config/#taskmanager-memory-jvm-overhead-fraction) | 用于其他 JVM 开销的本地内存，例如栈空间、垃圾回收空间等。该内存部分为基于[进程总内存](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup/#configure-total-memory)的[受限的等比内存部分](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/deployment/memory/mem_setup/#capped-fractionated-components)。约占处理内存的10% |



## REF

[1. Flink 架构 | Apache Flink](https://ci.apache.org/projects/flink/flink-docs-release-1.13/zh/docs/concepts/flink-architecture/)

[2.Apache Flink: 应用场景](https://flink.apache.org/zh/usecases.html)

[3. Apache Flink: Flink 用户](https://flink.apache.org/zh/poweredby.html)

[4. Flink 和 Iceberg 如何解决数据入湖面临的挑战 - 简书 (jianshu.com)](https://www.jianshu.com/p/47e50f9c2801)

[5. Flink 的背压机制（Back Pressure）_xiaopeigen的专栏-CSDN博客](https://blog.csdn.net/xiaopeigen/article/details/108318065)

