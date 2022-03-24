# HDFS基准测试

在本文中，介绍一些包含在Hadoop 发行版中的基准测试和测试工具。也就是说，我们看看基准测试 TestDFSIO 、NNBench 和 Terasort。因此，了解如何运行这些工具将帮助我们在架构、硬件和软件方面摆脱集群，衡量其性能，并与其他人分享和比较结果。

具体测试的场景：

- 在不同版本Hadoop上运行基准测试，使用相同的配置参数，来进行正确性对比测试
- 在不同版本Hadoop上运行基准测试，使用相同的配置参数，来进行性能对比测试
- 在相同版本Hadoop上运行基准测试，使用不同的配置参数，进行性能对比测试，发现问题

## Hadoop常用的基准测评工具

Hadoop 的基准测评进程有很多，以下几种最常用。

- `TestDFSIO`，主要用于测试 HDFS 的 I/O 性能。该进程使用一个 MapReduce 作业作为并行读/写文档的一种便捷途径
- `NNBench`，对具有一定负载的 NameNode 运行测试。
- `TeraSort`，基准用于测试MapReduce和HDFS，方法是尽快对一些数据进行排序，以衡量在集群中分发和映射减少文件的能力。
- `MRBench`，使用 mrbench 会多次运行一个小型作业。与 TeraSort 相互映射，该基准的主要目的是检验小型作业能否快速响应
- `Gridmix`，是一个基准测评进程套装。通过模拟一些真实常见的数据访问模式，Gridmix 能逼真地为一个集群的负载建模
- `TPCx-HS`，基于 TeraSort 的标准基准测评进程，来自事务处理性能委员会
- `HiBench Suite`，是Intel开源的大数据基准套件，它包含一组Hadoop、Spark和流媒体工作负载，包括排序、WordCount、TeraSort和增强的DFSIO等。它还包含Spark Streaming、Flink、Storm和Gearpump的几个流媒体工作负载。

本文主要目标为测试HDFS的基准测试，以下通过`TestDFSIO`、`NNBench`和`TeraSort`进行测试。

## 1.TestDFSIO

`TestDFSIO`用于测试hdfs的IO性能，使用一个mapReduce作业来并发的执行读写操作，每个map任务用于读或写每个文件，map输出用于收集与处理文件相关的统计信息，Reduce用于累计和统计信息，并产生summary。

### 1.1运行命令

```shell
# sudo -u hdfs hadoop jar  /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-client-jobclient-3.1.1.3.1.5.0-152-tests.jar TestDFSIO
21/09/14 16:20:05 INFO fs.TestDFSIO: TestDFSIO.1.8
Missing arguments.
Usage: TestDFSIO [genericOptions] -read [-random | -backward | -skip [-skipSize Size]] | -write | -append | -truncate | -clean [-compression codecClassName] [-nrFiles N] [-size Size[B|KB|MB|GB|TB]] [-resFile resultFileName] [-bufferSize Bytes] [-storagePolicy storagePolicyName] [-erasureCodePolicy erasureCodePolicyName]
```

DFSIO可以测试写操作和读操作，以MapReduce作业的方式运行，返回整个集群的I/O性能报告。DFSIO读写测试的位置在hdfs://namendoe:8020/benchmarks/TestDFSIO/io_data，其中读测试不会自己产生数据，必须先执行DFSIO写测试。

- -read：读测试，对每个文件读-size指定的字节数
- -write：写测试，对每个文件写-size指定的字节数
- -append：追加测试，对每个文件追加-size指定的字节数
- -truncate：截断测试，对每个文件截断至-size指定的字节数
- -clean：清除TestDFSIO在HDFS上生成数据
- -n：文件个数
- -size：每个文件的大小
- -resFile：生成测试报告的本地文件路径
- -bufferSize：每个mapper任务读写文件所用到的缓存区大小，默认为1000000字节。

### 1.2测试

#### 1.2.1测试写入速度

使用 TestDFSIO 向 HDFS 写入 10 个文档，每个文档大小为 10MB，测试写入速度。

```shell
# sudo -u hdfs hadoop jar  /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-client-jobclient-3.1.1.3.1.5.0-152-tests.jar TestDFSIO -write -nrFiles 50 -size 1024MB
```

#### 1.2.2测试读取速度

> 注意
>
> 该步骤读取数据依赖于上一步测试写入速度生成的数据。

使用 TestDFSIO 向 HDFS 读取 10 个文档，每个文档大小为 10MB，测试读取速度。

```shell
# sudo -u hdfs hadoop jar  /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-client-jobclient-3.1.1.3.1.5.0-152-tests.jar TestDFSIO -read -nrFiles 50 -size 1024MB
```

#### 1.2.3查看测试数据

```shell
# sudo -u hdfs hadoop fs -ls /benchmarks/TestDFSIO/
Found 4 items
drwxr-xr-x   - hdfs hdfs          0 2021-09-14 17:17 /benchmarks/TestDFSIO/io_control
drwxr-xr-x   - hdfs hdfs          0 2021-09-14 17:12 /benchmarks/TestDFSIO/io_data
drwxr-xr-x   - hdfs hdfs          0 2021-09-14 17:17 /benchmarks/TestDFSIO/io_read
drwxr-xr-x   - hdfs hdfs          0 2021-09-14 17:12 /benchmarks/TestDFSIO/io_write
```

- io_data: 测试写入速度任务生成的数据
- io_read：测试读取速度任务的结果
- io_write：测试写入速度任务的结果

#### 1.2.4查看结果

结果会最终保存在当前目录的`TestDFSIO_results.log`：

```shell
# more TestDFSIO_results.log     
----- TestDFSIO ----- : write
            Date & time: Wed Sep 15 09:23:59 CST 2021
        Number of files: 50				# 文件数量
 Total MBytes processed: 51200		# 处理数据大小，单位：mb
      Throughput mb/sec: 64.28		# 每秒吞吐量，单位：mb/s
 Average IO rate mb/sec: 72.91		# IO平均速率，单位：mb/s
  IO rate std deviation: 24				# IO速率标准偏差
     Test exec time sec: 330.9		# 测试执行时间，单位：秒

----- TestDFSIO ----- : read
            Date & time: Wed Sep 15 09:32:16 CST 2021
        Number of files: 50				# 文件数量
 Total MBytes processed: 51200		# 处理数据大小，单位：mb
      Throughput mb/sec: 63.14		# 每秒吞吐量，单位：mb/s
 Average IO rate mb/sec: 117.77		# 平均IO速率，单位：mb/s
  IO rate std deviation: 151.77		# IO速率标准偏差
     Test exec time sec: 318.72		# 测试执行时间，单位：秒
```

### 1.3清除测试数据

重新测试之前，最好将之前测试的数据进行清除，以免干扰。

```shell
# sudo -u hdfs hadoop jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-client-jobclient-3.1.1.3.1.5.0-152-tests.jar  TestDFSIO -clean
```

## 2.NNBench 测试 [NameNode Benchmark]

NNBench用于测试NameNode的负载，它会生成很多与HDFS相关的请求，给NameNode施加较大的压力。这个测试能在HDFS上模拟创建、读取、重命名和删除文件等操作。

### 2.1运行命令

```shell
# sudo -u hdfs hadoop jar  /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-client-jobclient-3.1.1.3.1.5.0-152-tests.jar nnbench

NameNode Benchmark 0.4
Usage: nnbench <options>
Options:
	-operation <Available operations are create_write open_read rename delete. This option is mandatory>
	 * NOTE: The open_read, rename and delete operations assume that the files they operate on, are already available. The create_write operation must be run before running the other operations.
	-maps <number of maps. default is 1. This is not mandatory>
	-reduces <number of reduces. default is 1. This is not mandatory>
	-startTime <time to start, given in seconds from the epoch. Make sure this is far enough into the future, so all maps (operations) will start at the same time. default is launch time + 2 mins. This is not mandatory>
	-blockSize <Block size in bytes. default is 1. This is not mandatory>
	-bytesToWrite <Bytes to write. default is 0. This is not mandatory>
	-bytesPerChecksum <Bytes per checksum for the files. default is 1. This is not mandatory>
	-numberOfFiles <number of files to create. default is 1. This is not mandatory>
	-replicationFactorPerFile <Replication factor for the files. default is 1. This is not mandatory>
	-baseDir <base DFS path. default is /benchmarks/NNBench. This is not mandatory>
	-readFileAfterOpen <true or false. if true, it reads the file and reports the average time to read. This is valid with the open_read operation. default is false. This is not mandatory>
	-help: Display the help statement
```

### 2.2测试

使用4个mapper和2个reducer创建10个文件，其中块大小设置为128MB。

```shell
# sudo -u hdfs hadoop jar  /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-client-jobclient-3.1.1.3.1.5.0-152-tests.jar nnbench -operation create_write -maps 4 -reduces 2 -numberOfFiles 10 -blockSize 134217728 -replicationFactorPerFile 3 -readFileAfterOpen true
```

### 2.3结果查看

结果会保存在当前目录下`NNBench_results.log`

```shell
# more NNBench_results.log

-------------- NNBench -------------- :
                               Version: NameNode Benchmark 0.4
                           Date & time: 2021-09-15 11:09:25,247

                        Test Operation: create_write
                            Start time: 2021-09-15 11:09:14,889
                           Maps to run: 4
                        Reduces to run: 2
                    Block Size (bytes): 134217728
                        Bytes to write: 0
                    Bytes per checksum: 1
                       Number of files: 10
                    Replication factor: 3
            Successful file operations: 40

        # maps that missed the barrier: 0
                          # exceptions: 0

               TPS: Create/Write/Close: 414
Avg exec time (ms): Create/Write/Close: 17.825
            Avg Lat (ms): Create/Write: 12.15
                   Avg Lat (ms): Close: 5.55

                 RAW DATA: AL Total #1: 486
                 RAW DATA: AL Total #2: 222
              RAW DATA: TPS Total (ms): 713
       RAW DATA: Longest Map Time (ms): 193.0
                   RAW DATA: Late maps: 0
             RAW DATA: # of exceptions: 0
             
```

## 3.TeraSort

TeraSort基准用于测试MapReduce和HDFS，方法是尽快对一些数据进行排序，以衡量在集群中分发和映射减少文件的能力。该基准由3个部分组成：

- **TeraGen -** 生成随机数据
- **TeraSort -** 使用MapReduce进行排序
- **TeraValidate -** 用于验证输出

### 3.1TeraGen

##### 3.1.1运行命令

```shell
# sudo -u hdfs hadoop jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples-3.1.1.3.1.5.0-152.jar teragen

teragen <num rows> <output dir>
```

- num rows:  数据行数，其中每条数据大小为100字节
- output dir：输出的hdfs路径

##### 3.1.2生成数据

通过以下命令生成10GB的随机数据：

```shell
# sudo -u hdfs hadoop jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples-3.1.1.3.1.5.0-152.jar teragen 107374182 /benchmarks/terasort/teragen
```

假设您想生成10 GB的数据，那么100字节的行数将是：

数据行数=10 GB/100字节 =10 * 1024 * 1024 * 1024 / 100 = 107374182

### 3.2**TeraSort**

##### 3.2.1运行命令

要对生成的数据进行排序，请使用以下命令。

```shell
# sudo -u hdfs hadoop jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples-3.1.1.3.1.5.0-152.jar terasort

 <in> <out>
```

- in：要排序的数据，这里即是TeraGen的output dir
- out: 排序结果输出路径

##### 3.2.2排序

```shell
# sudo -u hdfs hadoop jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples-3.1.1.3.1.5.0-152.jar terasort /benchmarks/terasort/teragen /benchmarks/terasort/terasort
```

### 3.3**TeraValidate**

##### 3.3.1运行命令

为确保数据排序正确，请使用以下命令。

```shell
# sudo -u hdfs hadoop jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples-3.1.1.3.1.5.0-152.jar teravalidate

<out-dir> <report-dir>
```

- out-dir:  上一步TeraSort的输出路径
- report-dir：报告输出路径

##### 3.3.2 验证

```shell
# sudo -u hdfs hadoop jar /usr/hdp/current/hadoop-mapreduce-client/hadoop-mapreduce-examples-3.1.1.3.1.5.0-152.jar teravalidate /benchmarks/terasort/terasort /benchmarks/terasort/teravalidate
```

##### 3.3.2 查看结果

```shell
# sudo -u hdfs hadoop fs -cat /benchmarks/terasort/teravalidate/part-r-00000

checksum	3333be4d3d281d2
```

验证terasort输出的结果是否有序，若是检查到有问题，将乱序的key输出到HDFS的report路径中。在report-dir文件下查看输出文件显示checksum表示排序没有问题，测试结束。

## Ref

- 【hadoop 基准测试】https://www.cnblogs.com/yjt1993/p/12972772.html

- 【HadoopBenchmarking】https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/Benchmarking.html

- 【Measuring HDP Performance, Scale and Reliability】https://community.cloudera.com/t5/Community-Articles/Measuring-HDP-Performance-Scale-and-Reliability/ta-p/244525

- 【Hadoop基准测试】https://www.dazhuanlan.com/lz1674343170/topics/1133985

- 【HiBench Suite】https://github.com/Intel-bigdata/HiBench

- 【**Bench marking and Stress Testing on HDP Hadoop Cluster with Terasort, TestDFSIO**】https://community.cloudera.com/legacyfs/online/attachments/5493-bench-marking-and-stress-testing-ilovepdf-compress.pdf

- 【Gridmix】https://hadoop.apache.org/docs/stable/hadoop-gridmix/GridMix.html

