## Pulsar部署文档

### 准备工作

目前，Pulsar可用于64位*macOS、Linux和Windows。要使用Pulsar，您需要安装64位JRE/JDK 8或更高版本。

机部署 Pulsar， 推荐如下配置：

- 至少 6 台 Linux 机器或虚拟机
  - 3 台部署[Zookeeper](https://zookeeper.apache.org/)
  - 3台部署 Pulsar broker 和 [Bookeeper](https://bookkeeper.apache.org/) bookie
- 包含 Pulsar 所有 broker 主机的 [DNS](https://en.wikipedia.org/wiki/Domain_Name_System)（域名解析服务器）

#### 网络要求

| 组件   | 端口 | 说明                                                         |
| ------ | ---- | ------------------------------------------------------------ |
| Broker | 8080 | 集群的 Web 服务 URL，加上一个端口。此 URL 应该是标准的 DNS 名称。默认端口为 8080 |
| Broker | 8443 | 如果使用[TLS](https://pulsar.apache.org/docs/en/security-tls-transport)，则还需要为集群指定 TLS Web 服务 URL。默认端口为 8443 |
| Broker | 6650 | 一个允许与集群中的代理交互的代理服务 URL。此 URL 不应使用与 Web 服务 URL 相同的 DNS 名称，而应使用`pulsar`方案。默认端口为 6650 |
| Broker | 6651 | 如果您使用[TLS](https://pulsar.apache.org/docs/en/security-tls-transport)，则还需要为集群指定 TLS Web 服务 URL 以及集群中代理的 TLS 代理服务 URL。默认端口为 6651 |
| Bookie | 8100 | Prometheus导出器的默认端口                                   |
| Bookie | 8000 | 要侦听的http服务器端口。默认值为8080。使用“8000”作为端口，使其与普罗米修斯的统计数据保持一致 |
| Bookie | 3181 | Bookie服务器在3181上监听的端口                               |

### 安装部署

##### 准备Pulsar安装包

拷贝apache-pulsar-2.8.0-bin.tar.gz到环境安装目录，如果支持外网可通过[get](https://www.gnu.org/software/wget) 命令下载:

```shell
$ wget https://archive.apache.org/dist/pulsar/pulsar-2.8.0/apache-pulsar-2.8.0-bin.tar.gz
```

包下载完成后，解压并`进入`到解压后的目录:

```shell
$ tar xvzf apache-pulsar-2.8.0-bin.tar.gz
$ cd apache-pulsar-2.8.0
```

解压后的文件目录包含以下子目录:

| 目录   | 内容                                                         |
| ------ | ------------------------------------------------------------ |
| `bin`  | Pulsar的命令行工具，如Pulsar和Pulsar admin                   |
| `conf` | Pulsar的配置文件，包含[broker配置](https://pulsar.apache.org/docs/zh-CN/reference-configuration#broker),[ZooKeeper 配置](https://pulsar.apache.org/docs/zh-CN/reference-configuration#zookeeper) 等等 |
| `data` | Zookeeper 和 Bookeeper 使用的数据保存目录                    |
| `lib`  | Pulsar 使用的[ JAR ](https://en.wikipedia.org/wiki/JAR_(file_format))文件 |
| `logs` | 日志目录                                                     |

### 部署 Zookeeper 集群

**如果你已经有 zookeeper 集群，并且你想复用它，你可以跳过这一步。**

ZooKeeper为Pulsar管理各种基本的协调和配置相关任务。部署Pulsar集群你必须首先部署 Zookeeper (在所有其他组件之前)。建议部署3个节点的 Zookeeper 集群。 Pulsar并没有大量使用ZooKeeper，所以运行ZooKeeper应该有更多的轻量级机器或虚拟机。

首先，将所有的 Zookeeper 服务器信息添加到[`conf/zookeeper.conf`](https://pulsar.apache.org/docs/zh-CN/reference-configuration#zookeeper)配置文件(文件在 Pulsar 的安装目录[里面](https://pulsar.apache.org/docs/zh-CN/deploy-bare-metal/#install-the-pulsar-binary-package))。 如下所示：

```
server.1=zk1.us-west.example.com:2888:3888
server.2=zk2.us-west.example.com:2888:3888
server.3=zk3.us-west.example.com:2888:3888
```

**如果你只有一台机器部署 Pulsar，你仅仅只需把加这台服务器添加到配置文件里面。**

在每台机器，你必须在每个节点的`myid`文件里面配置集群唯一的ID。默认情况下，这个文件在每台机器的`data/zookeeper`目录里面(你可以通过修改[`dataDir`](https://pulsar.apache.org/docs/zh-CN/reference-configuration#zookeeper-dataDir)配置项修改这个路径)。

**参考[多集群安装指南](https://zookeeper.apache.org/doc/r3.4.10/zookeeperAdmin.html#sc_zkMulitServerSetup)的Zookeeper 文档了解更多关于`myid`或者其他部分的详细信息。**

例如，在地址为`zk1.us-west.example.com`的Zookeeper 服务器上，你能够使用如下命令设置`myid`：

```
$ mkdir -p data/zookeeper
$ echo 1 > data/zookeeper/myid
```

在`zk2.us-west.example.com`服务器上，这命令可以是：`echo 2>data/zookeeper/myid`。

一旦你在每台机器增加了`zookeeper.conf`配置文件，并且设置了`myid`，你能够在所有机器上使用[`pulsar-daemon`](https://pulsar.apache.org/docs/zh-CN/reference-cli-tools#pulsar-daemon)命令去启动Zookeeper 服务(前台运行或者后台运行)。

```shell
$ bin/pulsar-daemon start zookeeper
```

### 初始化集群元数据

为集群部署ZooKeeper后，需要为实例中的每个集群向ZooKeeper写入一些元数据。您只需要写入此数据一次。

可以使用pulsar CLI工具的initialize cluster metadata命令初始化此元数据。此命令可以在ZooKeeper群集中的任何计算机上运行。如下所示：

```shell
$ bin/pulsar initialize-cluster-metadata \
  --cluster pulsar-cluster-1 \
  --zookeeper zk1.us-west.example.com:2181 \
  --configuration-store zk1.us-west.example.com:2181 \
  --web-service-url http://pulsar.us-west.example.com:8080 \
  --web-service-url-tls https://pulsar.us-west.example.com:8443 \
  --broker-service-url pulsar://pulsar.us-west.example.com:6650 \
  --broker-service-url-tls pulsar+ssl://pulsar.us-west.example.com:6651
```

从上面的示例中可以看出，您需要指定以下内容：

| 标记                     | 说明                                                         |
| ------------------------ | ------------------------------------------------------------ |
| --cluster                | 集群名称                                                     |
| --zookeeper              | ZooKeeper集群连接参数，仅需要包含ZooKeeper集群中的一个节点即可 |
| --configuration-store    | Pulsar实例的配置存储集群（ZooKeeper），多集群部署时才会发挥作用，需要另外部署ZooKeeper集群，但是单集群部署时可以和--zookeeper参数设置一样，只需要包含ZooKeeper集群中的一个节点即可 |
| --web-service-url        | 集群Web服务的URL+端口，URL是一个标准的DNS名称，默认端口8080，不建议修改 |
| --web-service-url-tls    | 集群Web提供TLS服务的URL+端口，端口默认8443，不建议修改。     |
| --broker-service-url     | 集群brokers服务URL，URL中DNS的名称和Web服务保持一致，URL使用pulsar替代http/http，端口默认6650，不建议修改。 |
| --broker-service-url-tls | 集群brokers提供TLS服务的URL，默认端口6551，不建议修改。      |

### 部署 Bookeeper 集群

Bookeeper 处理Pulsar中的所有持久数据存储。你必须先部署一个 BookKeeper 集群，才能够使用 Pulsar。您可以选择运行3-bookie BookKeeper 群集。

在每个部署bookkeeper的机器上，通过vim conf/bookkeeper.conf来编辑bookkeeper配置文件，修改如下关键配置项：

```
zkServers=zk1.us-west.example.com:2181,zk2.us-west.example.com:2181,zk3.us-west.example.com:2181
prometheusStatsHttpPort=8100
advertisedAddress=pulsar.us-west.example.com #服务对外发布的主机名或 IP 地址。 如果未设置，将使用 InnetAddress.getLocalHost().getHostName() 的值。

journalDirectory=data/bookkeeper/journal	#BookKeeper 输出 write-ahead 日志（WAL）的目录	
ledgerDirectories=data/bookkeeper/ledgers
#BookKeeper 输出 ledger 快照的目录。 这里可以定义多个目录来存储以逗号分隔的快照，比如 ledgerDirectories=/tmp/bk1-data,/tmp/bk2-data。 最理想的情况是，ledger 目录和日志目录都是在不同的设备中，这减少了随机读写和顺序写入之间的争执。 可以用单个磁盘运行，但性能将显著降低。
serverTcpNoDelay=false	
#此设置用于启用/禁用 Nagle 的算法，该算法能通过减少通过网络发送的数据包数量来提高 TCP/IP 网络效率。 如果你正在发送许多小消息，这样在单个 IP 数据包中就可以放入不止一个消息，设置 server.tcpnodelay 为 false 来启用 Nagle 算法可以提供更好的性能。	true
numReadWorkerThreads=0	处理读取请求的最大线程数。 如果设置为 0，读取请求将直接被 netty 线程处理。	8
```

详细配置可查看[配置](https://pulsar.apache.org/docs/zh-CN/2.5.1/reference-configuration/)

**注意：**

- prometheusStatsHttpPort默认是8000，但实际上在bookkeeper.conf中，httpServerPort默认也是8000，会导致端口被占用。
- 上面的advertisedAddress需要设置为对应机器的ip，而不是全设置为同一个

**参数说明：**

| 标记              | 说明                                                         |
| ----------------- | ------------------------------------------------------------ |
| advertisedAddress | 指定当前节点的主机名或IP地址                                 |
| zkServers         | 指定zookeeper集群，用来将bookkeeper节点的元数据存放在zookeeper集群 |

一旦修改完conf/bookkeeper.conf文件的相关配置，你就可以在每台 Bookeeper 机器上启动 bookie。

在三台机器上，分别输入以下命令来以后台进程启动bookie：

```shell
bin/pulsar-daemon start bookie
```

验证是否启动成功：

```shell
bin/bookkeeper shell bookiesanity
```

出现`Bookie sanity test succeeded`则代表启动成功。

如果需要关闭bookkeeper，可使用命令

```shell
bin/pulsar-daemon stop bookie
```

### Broker集群部署

在每个部署Broker的机器上，通过`vim conf/broker.conf`来编辑Broker配置文件，修改如下关键配置项：

```
zookeeperServers=zk1.us-west.example.com:2181,zk2.us-west.example.com:2181,zk3.us-west.example.com:2181
configurationStoreServers=zk1.us-west.example.com:2181,zk2.us-west.example.com:2181,zk3.us-west.example.com:2181
advertisedAddress=IP1
#clusterName与前面zookeeper初始化的cluster一致
clusterName=pulsar-cluster-zk
```

**注意：**
上面的advertisedAddress需要设置为对应机器的ip，而不是全设置为同一个

**参数说明：**

| 标记                      | 说明                                                         |
| ------------------------- | ------------------------------------------------------------ |
| zookeeperServers          | 指定zookeeper集群，用来将broker节点的元数据存放在zookeeper集群 |
| configurationStoreServers | 多集群部署时管理多个pulsar集群元数据的zookeeper集群地址，单集群部署时可以和zookeeperServers设置一样 |
| advertisedAddress         | 指定当前节点的主机名或IP地址                                 |
| clusterName               | 指定pulsar集群名称                                           |

如果你部署的是单节点的 Pulsar 集群，你需要把配置文件`conf/broker.conf`的副本数量配置为`1`

```
# Number of bookies to use when creating a ledger
managedLedgerDefaultEnsembleSize=1

# Number of copies to store for each message
managedLedgerDefaultWriteQuorum=1

# Number of guaranteed copies (acks to wait before write is complete)
managedLedgerDefaultAckQuorum=1
```

### 启用授权并分配超级用户

你可以在 broker 的([`conf/broker.conf`](https://pulsar.apache.org/docs/zh-CN/reference-configuration#broker))配置文件中启用授权并分配 superusers。

```shell
authorizationEnabled=true
superUserRoles=my-super-user-1,my-super-user-2
```

在每个部署Broker的机器上，以后台进程启动broker

```
bin/pulsar-daemon start broker
```

 如果需要关闭broker，可使用命令

```
bin/pulsar-daemon stop broker
```

查看集群 brokers 节点情况

```
bin/pulsar-admin brokers list pulsar-cluster
```

我们的示例部署正常的话，这一步会显示如下结果；
IP1:8080 IP2:8080 IP3:8080
代表此时集群内有存活的节点: IP1、IP2、IP3，端口号都是8080。到这一步，Pulsar的部署就完成了。

完成后，你能够发送消息到 Pulsar 主题：

```shell
$ bin/pulsar-client produce \
  persistent://public/default/test \
  -n 1 \
  -m "Hello Pulsar"
```

此命令将单个消息发布到Pulsar主题。此外，在发布消息之前，您可以在不同的终端上订阅Pulsar主题，如下所示：

```shell
$ bin/pulsar-client consume \
  persistent://public/default/test \
  -n 100 \
  -s "consumer-test" \
  -t "Exclusive"
```

一旦您成功地向主题发送了上面的消息，您应该在标准输出中看到它：

```shell
----- 收到消息 -----
Hello Pulsar
```

### 代理前端

Nginx前端部署负载均衡软件，使用Nginx负载均衡器。

创建Nginx配置pulsar_proxy.conf,配置内容如下：

```json
upstream pulsar_server {
    server BrokerIp1:8080;
    server BrokerIp2:8080;
    server BrokerIp3:8080;
    }

server {
    listen 9009;
    server_name  localhost;
    ignore_invalid_headers off;
    client_max_body_size 0;
    proxy_buffering off;
    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_connect_timeout 300;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        chunked_transfer_encoding off;
        proxy_pass http://pulsar_server;
    }
}
```

### Pulsar manage 安装

```shell
wget https://dist.apache.org/repos/dist/release/pulsar/pulsar-manager/pulsar-manager-0.2.0/apache-pulsar-manager-0.2.0-bin.tar.gz
tar -zxvf apache-pulsar-manager-0.2.0-bin.tar.gz
cd pulsar-manager
tar -xvf pulsar-manager.tar
cd pulsar-manager
cp -r ../dist ui
./bin/pulsar-manager
#后台运行 nohup sh bin/pulsar-manager >my.log 2>&1 & 
```

#### 配置用户名密码

```shell
CSRF_TOKEN=$(curl http://backend-service:7750/pulsar-manager/csrf-token)
curl \
    -H "X-XSRF-TOKEN: $CSRF_TOKEN" \
    -H "Cookie: XSRF-TOKEN=$CSRF_TOKEN;" \
    -H 'Content-Type: application/json' \
    -X PUT http://backend-service:7750/pulsar-manager/users/superuser \
    -d '{"name": "admin", "password": "apachepulsar", "description": "test", "email": "username@test.org"}'

```

- `backend-service`：后端服务的IP地址或域名。
- `password`：密码应大于等于6位。

现在，您可以通过以下地址访问它：frontend => http://localhost:7750/ui/index.html。

### REF

[Pulsar 官网部署](https://pulsar.apache.org/docs/zh-CN/deploy-bare-metal/#install-the-pulsar-binary-package)

[Pulsar 快速开始（集群搭建+Java demo）](https://zhuanlan.zhihu.com/p/272551491)

[Pulsar manage 安装](https://github.com/apache/pulsar-manager)