# hive-testbench

用于在任何数据规模上试验 Apache Hive 的测试平台。

# 概述

hive-testbench 是一个数据生成器和一组查询，可让您大规模试验 Apache Hive。测试台允许您在大型数据集上体验基本的 Hive 性能，并提供一种简单的方法来查看 Hive 调整参数和高级设置的影响。

# 条件

环境：

- Hadoop 3。
- Apache Hive.
- 生成数据需要 15 分钟到 2 天（取决于您选择的比例因子和可用硬件）。
- 如果您计划生成 1TB 或更多的数据，强烈建议使用 Apache Hive 13+ 生成数据。

# 安装和设置

准备hive-testbench包，通过github地址下载，下载完成拷贝到服务器。地址如下

```
https://github.com/hortonworks/hive-testbench
```

这些步骤都应该在您的 Hadoop 集群上执行。

- 第 1 步：准备您的环境。

  除了 Hadoop 和 Hive，在开始之前，请确保`gcc`已安装并在您的系统路径上可用。如果您的系统没有它，请使用 yum 或 apt-get 安装它。

- 第 2 步：决定要使用的测试套件。

  hive-testbench 带有基于 TPC-DS 和 TPC-H 基准的数据生成器和示例查询。您可以选择使用其中一个或两个基准进行实验。有关这些基准的更多信息可以在交易处理委员会主页上找到。

- 第 3 步：编译并打包相应的数据生成器。

  对于 TPC-DS，`./tpcds-build.sh`下载、编译和打包 TPC-DS 数据生成器。对于 TPC-H，`./tpch-build.sh`下载、编译和打包 TPC-H 数据生成器。

- 第 4 步：决定要生成多少数据。

  您需要决定一个“比例因子”，它代表您将生成多少数据。Scale Factor 粗略地转换为 GB，因此 100 的 Scale Factor 大约为 100 GB，1 TB 是 Scale Factor 1000。决定您需要多少数据，并在下一步中牢记它。如果您有一个由 4-10 个节点组成的集群，或者只想以较小的规模进行试验，那么规模 1000 (1 TB) 的数据是一个很好的起点。如果您有一个大型集群，您可能需要选择 Scale 10000 (10 TB) 或更多。TPC-DS 和 TPC-H 的比例因子的概念是相似的。

  如果要生成大量数据，则应使用 Hive 13 或更高版本。Hive 13 引入了一项优化，允许更可扩展的数据分区。如果生成超过几百 GB 的数据并且很难解决问题，Hive 12 及更低版本可能会崩溃。您可以在 Hive 13 中生成文本或 RCFile 数据，并在多个版本的 Hive 中使用它。

- 第 5 步：生成并加载数据。

  脚本`tpcds-setup.sh`和`tpch-setup.sh`分别为 TPC-DS 和 TPC-H 生成和加载数据。一般用法是`tpcds-setup.sh scale_factor [directory]`或`tpch-setup.sh scale_factor [directory]`

  一些例子：

  构建 1 TB TPC-DS 数据： `./tpcds-setup.sh 1000`

  构建 1 TB TPC-H 数据： `./tpch-setup.sh 1000`

  构建 100 TB 的 TPC-DS 数据： `./tpcds-setup.sh 100000`

  构建 30 TB 的文本格式 TPC-DS 数据： `FORMAT=textfile ./tpcds-setup 30000`

  构建 30 TB 的 RCFile 格式的 TPC-DS 数据： `FORMAT=rcfile ./tpcds-setup 30000`

  还要检查安装脚本中的其他参数，重要的是 BUCKET_DATA。

- 第 6 步：运行查询。

  包含 50 多个示例 TPC-DS 查询和所有 TPC-H 查询供您尝试。您可以使用`hive`，`beeline`或您选择的 SQL 工具。测试平台还包括一组建议设置。

  此示例假设您在步骤 5 中生成了 1 TB 的 TPC-DS 数据：
  打开spark 客户端

  ```shell
   source ${hive-testbench}/spark-queries-tpcds/q55.sql;
  ```