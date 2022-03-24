# ClickHouse集群部署

## 端口使用情况

| 组件 | 默认端口 | 说明                        |
| ---- | -------- | --------------------------- |
|      | 9000     | 通过TCP协议与客户端通讯端口 |
|      | 9004     | MySQL协议通讯端口           |
|      | 9005     | Postgresql协议通讯端口      |
|      | 9009     | 服务器之间交换数据的端口    |
|      | 8123     | HTTP通信端口                |
|      |          |                             |
|      |          |                             |
|      |          |                             |
|      |          |                             |

## 环境准备

服务器需要以下环境支持：

- Linux (Centos 7+)
- Java 1.8+

CPU需要支持SSE 4.2指令集，查看命令如下：

```
$ grep -q sse4_2 /proc/cpuinfo && echo "SSE 4.2 supported" || echo "SSE 4.2 not supported"
```

#### 安装包下载

https://repo.clickhouse.com/deb/stable/main/

- `clickhouse-common-static` — ClickHouse编译的二进制文件。
- `clickhouse-server` — 创建`clickhouse-server`软连接，并安装默认配置服务
- `clickhouse-client` — 创建`clickhouse-client`客户端工具软连接，并安装客户端配置文件。
- `clickhouse-common-static-dbg` — 带有调试信息的ClickHouse二进制文件。

#### 集群机器挂载ext4数据盘

生产环境部署，建议使用xfs类型文件系统直接以**JBOD**方式作为数据盘。

以root用户登陆到服务器上，以 `/dev/sdb` 数据盘为例，具体操作步骤如下：

(1)  查看数据盘

```shell
fdisk -l
```

(2)  创建分区

```shell
parted -s -a optimal /dev/sdb mklabel gpt -- mkpart primary ext4 1 -1
```

(3)  格式化文件系统

```shell
mkfs.ext4 /dev/sdb1
```

(4)  编辑 `/etc/fstab` 文件，添加以下信息

```shell
/dev/sdb1 /data1 ext4 defaults,nodelalloc,noatime 0 2
```

(5)  挂载数据盘

```shell
mkdir -p /data1 & mount -a
```

(6)  查看磁盘挂在情况，包含以下信息，说明情况

```shell
# mount -t ext4
/dev/sdb1 on /data1 type ext4 (rw,noatime,nodelalloc,data=ordered)

# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda               8:0    0   20G  0 disk
├─sda1            8:1    0    2M  0 part
├─sda2            8:2    0  512M  0 part /boot
└─sda3            8:3    0 19.5G  0 part
  ├─centos-root 253:0    0 17.5G  0 lvm  /
  └─centos-swap 253:1    0    2G  0 lvm  [SWAP]
sdb               8:16   0  400G  0 disk
└─sdb1            8:17   0  400G  0 part /data1
sr0              11:0    1  4.3G  0 rom
```

(7) 创建数据盘软链

``` shell
ln -s /data1/clickhouse/data /var/lib/clickhouse
```

#### 关闭防火墙

```shell
# systemctl status firewalld.service

# systemctl stop firewalld.service

# systemctl disable firewalld.service
```

#### 安装NTP

选取其中一台服务器作为ntp server，其他服务器作为ntp client。

## 部署

### 准备安装包

将安装RPM包上传到服务器，并解压到`/deploy/clickhouse-deploy/`

1. 采用rpm命令进行安装

```shell
 rpm -i ./clickhouse-common-static-21.9.4.35-2.x86_64.rpm  
 rpm -i ./clickhouse-server-21.9.4.35-2.noarch.rpm  
 rpm -i ./clickhouse-client-21.9.4.35-2.noarch.rpm  
```

2. 配置集群信息

vi /etc/clickhouse-server/config.d/metrika.xml

``` xml
<yandex>
    <zookeeper>
        <node index="1">
            <host>192.168.5.173</host>
            <port>2181</port>
        </node>
    </zookeeper>

    <remote_servers>
        <cluster_test>
            <shard>
                <replica>
                    <host>192.168.6.193</host>
                    <port>9000</port>
                    <user>default</user>
                    <password>123456</password>
                </replica>
            </shard>
            <shard>
                <replica>
                    <host>192.168.6.194</host>
                    <port>9000</port>
                    <user>default</user>
                    <password>123456</password>
                </replica>
            </shard>
            <shard>
                <replica>
                    <host>192.168.6.195</host>
                    <port>9000</port>
                    <user>default</user>
                    <password>123456</password>
                </replica>
            </shard>
        </cluster_test>
    </remote_servers>

    <macros>
        <cluster>cluster_test</cluster>
        <shard>01</shard>
        <replica>replica01</replica>
    </macros>

</yandex>
```

3. 在配置文件/etc/clickhouse-server/config.xml中添加对上述配置的引用

```
 <include_from>/etc/clickhouse-server/config.d/metrika.xml</include_from>
```

4. 启动集群

   ```
   clickhouse start
   ```

5. 查看集群信息

   ```shell
   clickhouse-client --password 123456 --query "select * from system.clusters;"
   ```

   

## Ref

[安装部署 | ClickHouse文档](https://clickhouse.com/docs/zh/getting-started/install/)

[使用教程 | ClickHouse文档](https://clickhouse.com/docs/zh/getting-started/tutorial/)



