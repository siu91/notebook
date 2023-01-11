> 以下部署方案适合在开发和测试环境中使用



## 概念

- **Master**. 主节点通常托管控制和管理整个系统的控制平面。

- **Worker**. 工作程序节点运行在其上部署的实际应用程序。

-  **[KubeKey](https://github.com/kubesphere/kubekey/blob/master/README_zh-CN.md)**. 从版本3.0.0开始，KubeSphere使用一个名为KubeKey的全新安装程序来替换旧的基于ansible的安装程序。



## Step 1: 准备主机

**系统要求**

| 系统                                                   | 每个节点最小要求                            |
| :----------------------------------------------------- | :------------------------------------------ |
| **Ubuntu** *16.04, 18.04*                              | CPU: 2 Cores, Memory: 4 G, Disk Space: 40 G |
| **Debian** *Buster, Stretch*                           | CPU: 2 Cores, Memory: 4 G, Disk Space: 40 G |
| **CentOS** *7*.x                                       | CPU: 2 Cores, Memory: 4 G, Disk Space: 40 G |
| **Red Hat Enterprise Linux 7**                         | CPU: 2 Cores, Memory: 4 G, Disk Space: 40 G |
| **SUSE Linux Enterprise Server 15/openSUSE Leap 15.2** | CPU: 2 Cores, Memory: 4 G, Disk Space: 40 G |

**节点要求**

- 所有节点必须可以通过SSH访问
- 所有节点时钟同步
- 所有节点必须可以使用`sudo`/`curl`/`openssl` 
  - Docker 可以自己安装或由`KubeKey`安装

> 注意：Docker 一定要提前安装，如果是在离线环境安装KubeSphere

**依赖项要求**

| Dependency  | Kubernetes Version ≥ 1.18 | Kubernetes Version < 1.18 | install                          |
| :---------- | :------------------------ | :------------------------ | -------------------------------- |
| `socat`     | 必须                      | 可选（但推荐）            | CentOS：yum install -y socat     |
| `conntrack` | 必须                      | 可选（但推荐）            | CentOS：yum install -y conntrack |
| `ebtables`  | 可选（但推荐）            | 可选（但推荐）            | CentOS：yum install -y ebtables  |
| `ipset`     | 可选（但推荐）            | 可选（但推荐）            | CentOS：yum install -y ipset     |

**网络和DNS要求**

- 确保`/etc/resolv.conf`中配置的DNS地址可用
- 如果配置了防火墙或安全组，确保下面的网络可依访问，推荐关闭防火墙

| services       | protocol       | action | start port | end port | comment                                 |
| -------------- | -------------- | ------ | ---------- | -------- | --------------------------------------- |
| ssh            | TCP            | allow  | 22         |          |                                         |
| etcd           | TCP            | allow  | 2379       | 2380     |                                         |
| apiserver      | TCP            | allow  | 6443       |          |                                         |
| calico         | TCP            | allow  | 9099       | 9100     |                                         |
| bgp            | TCP            | allow  | 179        |          |                                         |
| nodeport       | TCP            | allow  | 30000      | 32767    |                                         |
| master         | TCP            | allow  | 10250      | 10258    |                                         |
| dns            | TCP            | allow  | 53         |          |                                         |
| dns            | UDP            | allow  | 53         |          |                                         |
| local-registry | TCP            | allow  | 5000       |          | offline environment                     |
| local-apt      | TCP            | allow  | 5080       |          | offline environment                     |
| rpcbind        | TCP            | allow  | 111        |          | use NFS                                 |
| ipip           | IPENCAP / IPIP | allow  |            |          | calico needs to allow the ipip protocol |

> 建议：
>
> - 操作系统是干净的，未安装任何的其它软件
> - 如果容器镜像下载慢，推荐[为Docker Daemon配置注册表镜像](https://docs.docker.com/registry/recipes/mirror/#configure-the-docker-daemon)
>   - 或[参考](https://yeasy.gitbook.io/docker_practice/install/mirror)



三个示例节点如下：

| Host IP       | Host Name | Role         |
| :------------ | :-------- | :----------- |
| 192.168.5.141 | master1   | master, etcd |
| 192.168.5.142 | worker1   | worker       |
| 192.168.5.143 | worker2   | worker       |

设置hostname

```shell
hostnamectl set-hostname my-host-name
```



**CheckPoint**

- 主机操作系统版本

- 主机最低配置 2核8G/40G

- 主机[时钟同步](./linux/配置NTP)

- 主机hostname配置

- 依赖软件包

- [关闭防火墙](https://jingyan.baidu.com/article/359911f5bffb5257fe030630.html)

- [关闭SELinux](https://github.com/kubesphere/kubekey/blob/master/docs/turn-off-SELinux_zh-CN.md)

  

## Step 2: 下载 KubeKey

<!-- tabs:start -->

#### ** 访问Github太难了 **

```shell
wget -c https://kubesphere.io/download/kubekey-v1.0.0-linux-amd64.tar.gz -O - | tar -xz
```



#### ** 访问Github So Easy **

> Download KubeKey from [GitHub Release Page](https://github.com/kubesphere/kubekey/releases/tag/v1.0.0) or use the following command directly.

```shell
wget https://github.com/kubesphere/kubekey/releases/download/v1.0.0/kubekey-v1.0.0-linux-amd64.tar.gz -O - | tar -xz
```

<!-- tabs:end -->

让 `kk`变为可执行命令 :

```
chmod +x kk
```



## Step 3: 创建一个集群

> 对于多节点安装，需要通过指定的配置文件来创建集群。



### 1. 创建示例配置文件

命令：

```
./kk create config [--with-kubernetes version] [--with-kubesphere version] [(-f | --file) path]
```

>  支持的Kubernetes版本： **v1.15.12**， **v1.16.13**， **v1.17.9** （默认）， **v1.18.6**。
>
>  ./kk create config --with-kubernetes v1.18.6 --with-kubesphere v3.0.0 -f config-v1.18.6-v3.yaml



下面是一些供参考的示例：

- 您可以使用默认配置创建示例配置文件。您还可以指定具有不同文件名的文件，也可以指定在不同文件夹中的文件。

```
./kk create config [-f ~/myfolder/abc.yaml]
```

- 您可以在 中自定义持久存储插件（例如 NFS 客户端、Ceph RBD 和 GlusterFS）。`config-sample.yaml`

```
./kk create config --with-storage localVolume
```



> 注意：
>
> ​		默认情况下，KubeKey[将安装 OpenEBS](https://openebs.io/)来为开发和测试环境预配[LocalPV](https://kubernetes.io/docs/concepts/storage/volumes/#local)，这对于新用户来说非常方便。在此示例中，使用默认存储类（本地卷）。对于生产，请使用 NFS/Ceph/GlusterFS/CSI 或商业产品作为持久存储解决方案。您需要在 下指定它们。有关详细信息[，请参阅持久](https://kubesphere.com.cn/en/docs/installing-on-linux/introduction/storage-configuration)存储配置。`addons``config-sample.yaml`



### 2. 编辑配置文件

如果不更改名称，将创建默认文件**config-sample.yaml。**编辑该文件，下面是一个带一个主节点的多节点群集的配置文件示例。

```
spec:
  hosts:
  - {name: master, address: 192.168.0.2, internalAddress: 192.168.0.2, user: ubuntu, password: Testing123}
  - {name: node1, address: 192.168.0.3, internalAddress: 192.168.0.3, user: ubuntu, password: Testing123}
  - {name: node2, address: 192.168.0.4, internalAddress: 192.168.0.4, user: ubuntu, password: Testing123}
  roleGroups:
    etcd:
    - master
    master:
    - master
    worker:
    - node1
    - node2
  controlPlaneEndpoint:
    domain: lb.kubesphere.local
    address: ""
    port: "6443"
```

#### 主机

- 列出所有计算机，并添加其详细信息，如上所示。在这种情况下，端口 22 是 SSH 的默认端口。否则，您需要在 IP 地址之后添加端口号。例如：`hosts`

```
hosts:
  - {name: master, address: 192.168.0.2, internalAddress: 192.168.0.2, port: 8022, user: ubuntu, password: Testing123}
```

- 对于默认root用户（不需要指定用户名）：

```
hosts:
  - {name: master, address: 192.168.0.2, internalAddress: 192.168.0.2, password: Testing123}
```

- 对于使用 SSH 密钥的无密码登录：

```
hosts:
  - {name: master, address: 192.168.0.2, internalAddress: 192.168.0.2, privateKeyPath: "~/.ssh/id_rsa"}
```

#### 角色组

- `etcd`： etcd节点名称
- `master`： master点名称
- `worker`： worker节点名称



#### controlPlaneEndpoint（仅适用于 HA 安装）

controlPlaneEndpoint允许您为 HA 群集定义外部负载均衡器。您需要准备和配置外部负载均衡器，如果且仅在需要安装 3 个多个主节点时。请注意，地址和端口应缩进 中的两个空格，并且 应为 VIP。有关详细信息，请参阅 HA 配置。`config-sample.yaml address`



> 提示
>
> - 您可以通过编辑配置文件来启用多群集功能。有关详细信息，请参阅多群集管理。
> - 您还可以选择要安装的组件。有关详细信息，请参阅[启用可插拔组件](https://kubesphere.com.cn/en/docs/pluggable-components/)。有关完整配置示例.yaml 文件的示例，请参阅[此文件](https://github.com/kubesphere/kubekey/blob/master/docs/config-example.md)。

完成编辑后，保存文件。

### 3. 使用配置文件创建群集

```
./kk create cluster -f config-sample.yaml
```

> 注意
>
> 如果使用其他名称，则需要将上面更改为自己的文件。`config-sample.yaml`

整个安装过程可能需要 10-20 分钟，具体取决于您的计算机和网络。

### 4. 验证安装

**查看安装结果**

```shell
kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f
```

安装完成后，您可以看到内容，如下所示：

```shell
#####################################################
###              Welcome to KubeSphere!           ###
#####################################################

Console: http://192.168.0.2:30880
Account: admin
Password: P@88w0rd

NOTES：
  1. After logging into the console, please check the
     monitoring status of service components in
     the "Cluster Management". If any service is not
     ready, please wait patiently until all components
     are ready.
  2. Please modify the default password after login.

#####################################################
https://kubesphere.io             20xx-xx-xx xx:xx:xx
#####################################################
```

现在，您将能够在 帐户和密码中访问 KubeSphere 的 Web 控制台。`http://{IP}:30880  admin/P@88w0rd`

> 注意
>
> 要访问控制台，您可能需要根据云提供商的平台将源端口转发到 Intranet IP 的 Intranet 端口。请确保在安全组中打开端口 30880。



![kubesphere-login](./assets/login.png)



## 启用 kubectl 自动完成

库贝基不启用 kubectl 自动完成。请参阅下面的内容并打开它：

**先决条件**：确保安装 `bash-autocompletion`

```
# Install bash-completion
apt-get install bash-completion

# Source the completion script in your ~/.bashrc file
echo 'source <(kubectl completion bash)' >>~/.bashrc

# Add the completion script to the /etc/bash_completion.d directory
kubectl completion bash >/etc/bash_completion.d/kubectl
```

详细信息可在此[找到](https://kubernetes.io/docs/tasks/tools/install-kubectl/#enabling-shell-autocompletion)。



## ref

[KubeSphere 3.0 快速安装入门必读清单](https://kubesphere.com.cn/forum/d/2062-awesome-kubesphere-kubesphere-3-0)

[**KubeSphere 3.0 重磅发布**](https://www.qingcloud.com/kubesphere2020)

[KubeSphere v2.1文档](https://v2-1.docs.kubesphere.io/docs/zh-CN/configuration/image-registry/)

[Multi-node Installation](https://kubesphere.com.cn/en/docs/installing-on-linux/introduction/multioverview/)

[KubeSphere HA 部署](https://kubesphere.io/docs/installing-on-linux/on-premises/install-kubesphere-on-vmware-vsphere/)

[测试版:KubeKey 离线环境部署 KubeSphere v3.0.0](https://kubesphere.com.cn/forum/d/2034-kubekey-kubesphere-v3-0-0)

[离线部署KubeSphere](https://v3-0.docs.kubesphere.io/docs/installing-on-linux/introduction/air-gapped-installation/)



## 附录

### 名词解释

了解和使用 KubeSphere 管理平台，会涉及到以下的基本概念：

| KubeSphere   | Kubernetes 对照释义                                          |
| :----------- | :----------------------------------------------------------- |
| 项目         | Namespace， 为 Kubernetes 集群提供虚拟的隔离作用，详见 [Namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)。 |
| 容器组       | Pod，是 Kubernetes 进行资源调度的最小单位，每个 Pod 中运行着一个或多个密切相关的业务容器 |
| 部署         | Deployments，表示用户对 Kubernetes 集群的一次更新操作，详见 [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)。 |
| 有状态副本集 | StatefulSets，用来管理有状态应用，可以保证部署和 scale 的顺序，详见 [StatefulSet](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)。 |
| 守护进程集   | DaemonSet，保证在每个 Node 上都运行一个容器副本，常用来部署一些集群的日志、监控或者其他系统管理应用，详见 [Daemonset](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/)。 |
| 任务         | Jobs，在 Kubernetes 中用来控制批处理型任务的资源对象，即仅执行一次的任务，它保证批处理任务的一个或多个 Pod 成功结束。任务管理的 Pod 根据用户的设置将任务成功完成就自动退出了。比如在创建工作负载前，执行任务，将镜像上传至镜像仓库。详见 [Job](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/)。 |
| 定时任务     | CronJob，是基于时间的 Job，就类似于 Linux 系统的 crontab，在指定的时间周期运行指定的 Job，在给定时间点只运行一次或周期性地运行。详见 [CronJob](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/) |
| 服务         | Service， 一个 Kubernete 服务是一个最小的对象，类似 Pod，和其它的终端对象一样，详见 [Service](https://kubernetes.io/docs/concepts/services-networking/service/)。 |
| 应用路由     | Ingress，是授权入站连接到达集群服务的规则集合。可通过 Ingress 配置提供外部可访问的 URL、负载均衡、SSL、基于名称的虚拟主机等，详见 [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)。 |
| 镜像仓库     | Image Registries，镜像仓库用于存放 Docker 镜像，包括公共镜像仓库（如 DockerHub）和私有镜像仓库（如 Harbor） |
| 存储卷       | PersistentVolumeClaim（PVC），满足用户对于持久化存储的需求，用户将 Pod 内需要持久化的数据挂载至存储卷，删除 Pod 后，数据仍保留在存储卷内。Kubesphere 推荐使用动态分配存储，当集群管理员配置存储类型后，集群用户可一键式分配和回收存储卷，无需关心存储底层细节。详见 [Volume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims)。 |
| 存储类型     | StorageClass，为管理员提供了描述存储 “Class（类）” 的方法，包含 Provisioner、 ReclaimPolicy 和 Parameters 。详见 [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/)。 |
| 流水线       | Pipeline，简单来说就是一套运行在 Jenkins 上的 CI/CD 工作流框架，将原来独立运行于单个或者多个节点的任务连接起来，实现单个任务难以完成的复杂流程编排和可视化的工作。 |
| 企业空间     | Workspace，是 KubeSphere 实现多租户模式的基础，是您管理项目、 DevOps 工程和企业成员的基本单位。 |
| 主机         | Node，Kubernetes 集群中的计算能力由 Node 提供，Kubernetes 集群中的 Node 是所有 Pod 运行所在的工作主机，可以是物理机也可以是虚拟机。详见 [Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/)。 |
| S2i          | Source to Image，通过代码构建新的容器镜像，表示从已有的代码仓库中获取代码，并通过 Source to Image 的方式构建镜像的方式来完成部署，每次构建镜像的过程将以任务 (Job) 的方式去完成。 |
| B2i          | Binary to Image，通过上传制品的方式，自动构建镜像和完成部署，并将镜像推送至目标仓库，仅需要通过简单的设置即可将制品快速构建成服务。 |
| 蓝绿部署     | 提供了一种零宕机的部署方式，在保留旧版本的同时部署新版本，将两个版本同时在线，如果有问题可以快速处理 |
| 金丝雀发布   | 将一部分真实流量引入一个新版本进行测试，测试新版本的性能和表现，在保证系统整体稳定运行的前提下，尽早发现新版本在实际环境上的问题。 |
| 流量镜像     | 流量镜像功能通常用于在生产环境进行测试，是将生产流量镜像拷贝到测试集群或者新的版本中，在引导用户的真实流量之前对新版本进行测试，旨在有效地降低新版本上线的风险。 |

### 安装配置

```yacas
apiVersion: kubekey.kubesphere.io/v1alpha1
kind: Cluster
metadata:
  name: sample
spec:
  hosts:
  - {name: master1, address: 192.168.5.141, internalAddress: 192.168.5.141, password: pass}
  - {name: worker1, address: 192.168.5.142, internalAddress: 192.168.5.142, password: pass}
  - {name: worker2, address: 192.168.5.143, internalAddress: 192.168.5.143, password: pass}
  roleGroups:
    etcd:
    - master1
    master:
    - master1
    worker:
    - worker1
    - worker2
  controlPlaneEndpoint:
    domain: lb.kubesphere.local
    address: ""
    port: "6443"
  kubernetes:
    version: v1.18.6
    imageRepo: kubesphere
    clusterName: cluster.local
  network:
    plugin: calico
    kubePodsCIDR: 10.233.64.0/18
    kubeServiceCIDR: 10.233.0.0/18
  registry:
    registryMirrors: []
    insecureRegistries: []
  addons: []


---
apiVersion: installer.kubesphere.io/v1alpha1
kind: ClusterConfiguration
metadata:
  name: ks-installer
  namespace: kubesphere-system
  labels:
    version: v3.0.0
spec:
  local_registry: ""
  persistence:
    storageClass: ""
  authentication:
    jwtSecret: ""
  etcd:
    monitoring: true
    endpointIps: localhost
    port: 2379
    tlsEnable: true
  common:
    es:
      elasticsearchDataVolumeSize: 20Gi
      elasticsearchMasterVolumeSize: 4Gi
      elkPrefix: logstash
      logMaxAge: 7
    mysqlVolumeSize: 20Gi
    minioVolumeSize: 20Gi
    etcdVolumeSize: 20Gi
    openldapVolumeSize: 2Gi
    redisVolumSize: 2Gi
  console:
    enableMultiLogin: false  # enable/disable multi login
    port: 30880
  alerting:
    enabled: false
  auditing:
    enabled: false
  devops:
    enabled: false
    jenkinsMemoryLim: 2Gi
    jenkinsMemoryReq: 1500Mi
    jenkinsVolumeSize: 8Gi
    jenkinsJavaOpts_Xms: 512m
    jenkinsJavaOpts_Xmx: 512m
    jenkinsJavaOpts_MaxRAM: 2g
  events:
    enabled: false
    ruler:
      enabled: true
      replicas: 2
  logging:
    enabled: false
    logsidecarReplicas: 2
  metrics_server:
    enabled: true
  monitoring:
    prometheusMemoryRequest: 400Mi
    prometheusVolumeSize: 20Gi
  multicluster:
    clusterRole: none  # host | member | none
  networkpolicy:
    enabled: false
  notification:
    enabled: false
  openpitrix:
    enabled: false
  servicemesh:
    enabled: false
```



### 完整安装日志

```shell
[root@master1 kubesphere]# ./kk create cluster -f config-v1.18.6-v3.yaml
+---------+------+------+---------+----------+-------+-------+-----------+--------+------------+-------------+------------------+--------------+
| name    | sudo | curl | openssl | ebtables | socat | ipset | conntrack | docker | nfs client | ceph client | glusterfs client | time         |
+---------+------+------+---------+----------+-------+-------+-----------+--------+------------+-------------+------------------+--------------+
| master1 | y    | y    | y       | y        | y     | y     | y         | y      | y          |             | y                | CST 20:56:49 |
| worker2 | y    | y    | y       | y        | y     | y     | y         | y      | y          |             | y                | CST 20:56:49 |
| worker1 | y    | y    | y       | y        | y     | y     | y         | y      | y          |             | y                | CST 20:56:49 |
+---------+------+------+---------+----------+-------+-------+-----------+--------+------------+-------------+------------------+--------------+

This is a simple check of your environment.
Before installation, you should ensure that your machines meet all requirements specified at
https://github.com/kubesphere/kubekey#requirements-and-recommendations

Continue this installation? [yes/no]: yes
INFO[20:56:58 CST] Downloading Installation Files
INFO[20:56:58 CST] Downloading kubeadm ...
INFO[20:56:58 CST] Downloading kubelet ...
INFO[20:56:59 CST] Downloading kubectl ...
INFO[20:56:59 CST] Downloading kubecni ...
INFO[20:56:59 CST] Downloading helm ...
INFO[20:56:59 CST] Configurating operating system ...
[worker2 192.168.5.143] MSG:
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_local_reserved_ports = 30000-32767
[master1 192.168.5.141] MSG:
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_local_reserved_ports = 30000-32767
[worker1 192.168.5.142] MSG:
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_local_reserved_ports = 30000-32767
INFO[20:57:01 CST] Installing docker ...
INFO[20:57:02 CST] Start to download images on all nodes
[worker2] Downloading image: kubesphere/pause:3.2
[master1] Downloading image: kubesphere/etcd:v3.3.12
[worker1] Downloading image: kubesphere/pause:3.2
[master1] Downloading image: kubesphere/pause:3.2
[worker2] Downloading image: kubesphere/kube-proxy:v1.18.6
[worker2] Downloading image: coredns/coredns:1.6.9
[master1] Downloading image: kubesphere/kube-apiserver:v1.18.6
[worker2] Downloading image: kubesphere/k8s-dns-node-cache:1.15.12
[worker1] Downloading image: kubesphere/kube-proxy:v1.18.6
[worker2] Downloading image: calico/kube-controllers:v3.15.1
[master1] Downloading image: kubesphere/kube-controller-manager:v1.18.6
[worker1] Downloading image: coredns/coredns:1.6.9
[master1] Downloading image: kubesphere/kube-scheduler:v1.18.6
[worker2] Downloading image: calico/cni:v3.15.1
[worker1] Downloading image: kubesphere/k8s-dns-node-cache:1.15.12
[master1] Downloading image: kubesphere/kube-proxy:v1.18.6
[worker2] Downloading image: calico/node:v3.15.1
[worker1] Downloading image: calico/kube-controllers:v3.15.1
[master1] Downloading image: coredns/coredns:1.6.9
[worker2] Downloading image: calico/pod2daemon-flexvol:v3.15.1
[worker1] Downloading image: calico/cni:v3.15.1
[worker1] Downloading image: calico/node:v3.15.1
[master1] Downloading image: kubesphere/k8s-dns-node-cache:1.15.12
[worker1] Downloading image: calico/pod2daemon-flexvol:v3.15.1
[master1] Downloading image: calico/kube-controllers:v3.15.1
[master1] Downloading image: calico/cni:v3.15.1
[master1] Downloading image: calico/node:v3.15.1
[master1] Downloading image: calico/pod2daemon-flexvol:v3.15.1
INFO[20:57:38 CST] Generating etcd certs
INFO[20:57:39 CST] Synchronizing etcd certs
INFO[20:57:39 CST] Creating etcd service
INFO[20:57:41 CST] Starting etcd cluster
[master1 192.168.5.141] MSG:
Configuration file will be created
INFO[20:57:41 CST] Refreshing etcd configuration
Waiting for etcd to start
INFO[20:57:47 CST] Get cluster status
[master1 192.168.5.141] MSG:
Cluster will be created.
INFO[20:57:47 CST] Installing kube binaries
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/kubeadm to 192.168.5.143:/tmp/kubekey/kubeadm   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/kubeadm to 192.168.5.141:/tmp/kubekey/kubeadm   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/kubeadm to 192.168.5.142:/tmp/kubekey/kubeadm   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/kubelet to 192.168.5.143:/tmp/kubekey/kubelet   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/kubelet to 192.168.5.142:/tmp/kubekey/kubelet   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/kubelet to 192.168.5.141:/tmp/kubekey/kubelet   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/kubectl to 192.168.5.143:/tmp/kubekey/kubectl   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/kubectl to 192.168.5.142:/tmp/kubekey/kubectl   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/kubectl to 192.168.5.141:/tmp/kubekey/kubectl   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/helm to 192.168.5.142:/tmp/kubekey/helm   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/helm to 192.168.5.143:/tmp/kubekey/helm   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/helm to 192.168.5.141:/tmp/kubekey/helm   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/cni-plugins-linux-amd64-v0.8.6.tgz to 192.168.5.142:/tmp/kubekey/cni-plugins-linux-amd64-v0.8.6.tgz   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/cni-plugins-linux-amd64-v0.8.6.tgz to 192.168.5.143:/tmp/kubekey/cni-plugins-linux-amd64-v0.8.6.tgz   Done
Push /opt/k8s/kubesphere/kubekey/v1.18.6/amd64/cni-plugins-linux-amd64-v0.8.6.tgz to 192.168.5.141:/tmp/kubekey/cni-plugins-linux-amd64-v0.8.6.tgz   Done
INFO[20:57:52 CST] Initializing kubernetes cluster
[master1 192.168.5.141] MSG:
W0915 20:57:52.197772   14421 utils.go:26] The recommended value for "clusterDNS" in "KubeletConfiguration" is: [10.233.0.10]; the provided value is: [169.254.25.10]
W0915 20:57:52.197914   14421 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[init] Using Kubernetes version: v1.18.6
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [master1 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local lb.kubesphere.local kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local localhost lb.kubesphere.local master1 master1.cluster.local worker1 worker1.cluster.local worker2 worker2.cluster.local] and IPs [10.233.0.1 192.168.5.141 127.0.0.1 192.168.5.141 192.168.5.142 192.168.5.143 10.233.0.1]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] External etcd mode: Skipping etcd/ca certificate authority generation
[certs] External etcd mode: Skipping etcd/server certificate generation
[certs] External etcd mode: Skipping etcd/peer certificate generation
[certs] External etcd mode: Skipping etcd/healthcheck-client certificate generation
[certs] External etcd mode: Skipping apiserver-etcd-client certificate generation
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
W0915 20:57:55.925155   14421 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
W0915 20:57:55.931888   14421 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[control-plane] Creating static Pod manifest for "kube-scheduler"
W0915 20:57:55.934288   14421 manifests.go:225] the default kube-apiserver authorization-mode is "Node,RBAC"; using "Node,RBAC"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 22.003530 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.18" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node master1 as control-plane by adding the label "node-role.kubernetes.io/master=''"
[mark-control-plane] Marking the node master1 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: suv5ff.1xgwt173drrhzwmf
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:

  kubeadm join lb.kubesphere.local:6443 --token suv5ff.1xgwt173drrhzwmf \
    --discovery-token-ca-cert-hash sha256:eea4b8498e6e94c4ee40349f418f0e1f96a90678375c9446d39cc1cc4e74cdc1 \
    --control-plane

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join lb.kubesphere.local:6443 --token suv5ff.1xgwt173drrhzwmf \
    --discovery-token-ca-cert-hash sha256:eea4b8498e6e94c4ee40349f418f0e1f96a90678375c9446d39cc1cc4e74cdc1
[master1 192.168.5.141] MSG:
service "kube-dns" deleted
[master1 192.168.5.141] MSG:
service/coredns created
[master1 192.168.5.141] MSG:
serviceaccount/nodelocaldns created
daemonset.apps/nodelocaldns created
[master1 192.168.5.141] MSG:
configmap/nodelocaldns created
[master1 192.168.5.141] MSG:
I0915 20:58:43.231548   16131 version.go:252] remote version is much newer: v1.19.1; falling back to: stable-1.18
W0915 20:58:43.963531   16131 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
[upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
[upload-certs] Using certificate key:
ccc4f0d9e4006645de38d9bf8b5972c3e56c44d2fa73d0a38ebafdaa3865727c
[master1 192.168.5.141] MSG:
secret/kubeadm-certs patched
[master1 192.168.5.141] MSG:
secret/kubeadm-certs patched
[master1 192.168.5.141] MSG:
secret/kubeadm-certs patched
[master1 192.168.5.141] MSG:
W0915 20:58:44.380457   16322 configset.go:202] WARNING: kubeadm cannot validate component configs for API groups [kubelet.config.k8s.io kubeproxy.config.k8s.io]
kubeadm join lb.kubesphere.local:6443 --token f6cdpv.ooarwxar87ixuk8i     --discovery-token-ca-cert-hash sha256:eea4b8498e6e94c4ee40349f418f0e1f96a90678375c9446d39cc1cc4e74cdc1
[master1 192.168.5.141] MSG:
NAME      STATUS     ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
master1   NotReady   master   28s   v1.18.6   192.168.5.141   <none>        CentOS Linux 7 (Core)   3.10.0-862.el7.x86_64   docker://19.3.8
INFO[20:58:44 CST] Deploying network plugin ...
[master1 192.168.5.141] MSG:
configmap/calico-config created
customresourcedefinition.apiextensions.k8s.io/bgpconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/bgppeers.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/blockaffinities.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/clusterinformations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/felixconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/globalnetworksets.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/hostendpoints.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamblocks.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamconfigs.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ipamhandles.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/ippools.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/kubecontrollersconfigurations.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networkpolicies.crd.projectcalico.org created
customresourcedefinition.apiextensions.k8s.io/networksets.crd.projectcalico.org created
clusterrole.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrolebinding.rbac.authorization.k8s.io/calico-kube-controllers created
clusterrole.rbac.authorization.k8s.io/calico-node created
clusterrolebinding.rbac.authorization.k8s.io/calico-node created
daemonset.apps/calico-node created
serviceaccount/calico-node created
deployment.apps/calico-kube-controllers created
serviceaccount/calico-kube-controllers created
INFO[20:58:46 CST] Joining nodes to cluster
[worker2 192.168.5.143] MSG:
W0915 20:58:46.473031   13417 join.go:346] [preflight] WARNING: JoinControlPane.controlPlane settings will be ignored when control-plane flag is not set.
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
W0915 20:58:47.311000   13417 utils.go:26] The recommended value for "clusterDNS" in "KubeletConfiguration" is: [10.233.0.10]; the provided value is: [169.254.25.10]
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.18" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
[worker1 192.168.5.142] MSG:
W0915 20:58:46.492210   13416 join.go:346] [preflight] WARNING: JoinControlPane.controlPlane settings will be ignored when control-plane flag is not set.
[preflight] Running pre-flight checks
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -oyaml'
W0915 20:58:47.272964   13416 utils.go:26] The recommended value for "clusterDNS" in "KubeletConfiguration" is: [10.233.0.10]; the provided value is: [169.254.25.10]
[kubelet-start] Downloading configuration for the kubelet from the "kubelet-config-1.18" ConfigMap in the kube-system namespace
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
[worker1 192.168.5.142] MSG:
node/worker1 labeled
[worker2 192.168.5.143] MSG:
node/worker2 labeled
[master1 192.168.5.141] MSG:
storageclass.storage.k8s.io/local created
serviceaccount/openebs-maya-operator created
clusterrole.rbac.authorization.k8s.io/openebs-maya-operator created
clusterrolebinding.rbac.authorization.k8s.io/openebs-maya-operator created
configmap/openebs-ndm-config created
daemonset.apps/openebs-ndm created
deployment.apps/openebs-ndm-operator created
deployment.apps/openebs-localpv-provisioner created
INFO[20:58:55 CST] Deploying KubeSphere ...
v3.0.0
[master1 192.168.5.141] MSG:
namespace/kubesphere-system created
namespace/kubesphere-monitoring-system created
[master1 192.168.5.141] MSG:
secret/kube-etcd-client-certs created
[master1 192.168.5.141] MSG:
namespace/kubesphere-system unchanged
serviceaccount/ks-installer unchanged
customresourcedefinition.apiextensions.k8s.io/clusterconfigurations.installer.kubesphere.io unchanged
clusterrole.rbac.authorization.k8s.io/ks-installer unchanged
clusterrolebinding.rbac.authorization.k8s.io/ks-installer unchanged
deployment.apps/ks-installer unchanged
clusterconfiguration.installer.kubesphere.io/ks-installer created


INFO[21:04:12 CST] Installation is complete.

Please check the result using the command:

       kubectl logs -n kubesphere-system $(kubectl get pod -n kubesphere-system -l app=ks-install -o jsonpath='{.items[0].metadata.name}') -f

```

### 安装配置(HA)

```yacas
apiVersion: kubekey.kubesphere.io/v1alpha1
kind: Cluster
metadata:
  name: dev-cluster-config
spec:
  hosts:
  - {name: master1, address: 192.168.5.141, internalAddress: 192.168.5.141, password: pass}
  - {name: master2, address: 192.168.5.142, internalAddress: 192.168.5.142, password: pass}
  - {name: master3, address: 192.168.5.143, internalAddress: 192.168.5.143, password: pass}
  - {name: worker01, address: 192.168.5.145, internalAddress: 192.168.5.145, password: pass}
  - {name: worker02, address: 192.168.5.146, internalAddress: 192.168.5.146, password: pass}
  - {name: worker03, address: 192.168.5.147, internalAddress: 192.168.5.147, password: pass}
  roleGroups:
    etcd:
    - master1
    - master2
    - master3
    master:
    - master1
    - master2
    - master3
    worker:
    - worker01
    - worker02
    - worker03
  controlPlaneEndpoint:
    domain: lb.kubesphere.local
    address: "192.168.5.148"
    port: "6443"  
  kubernetes:
    version: v1.18.6
    imageRepo: kubesphere
    clusterName: cluster.local
    masqueradeAll: false  # masqueradeAll tells kube-proxy to SNAT everything if using the pure iptables proxy mode. [Default: false]
    maxPods: 110  # maxPods is the number of pods that can run on this Kubelet. [Default: 110]
    nodeCidrMaskSize: 24  # internal network node size allocation. This is the size allocated to each node on your network. [Default: 24]
    proxyMode: ipvs  # mode specifies which proxy mode to use. [Default: ipvs]
  network:
    plugin: calico
    calico:
      ipipMode: Always  # IPIP Mode to use for the IPv4 POOL created at start up. If set to a value other than Never, vxlanMode should be set to "Never". [Always | CrossSubnet | Never] [Default: Always]
      vxlanMode: Never  # VXLAN Mode to use for the IPv4 POOL created at start up. If set to a value other than Never, ipipMode should be set to "Never". [Always | CrossSubnet | Never] [Default: Never]
      vethMTU: 1440  # The maximum transmission unit (MTU) setting determines the largest packet size that can be transmitted through your network. [Default: 1440]
    kubePodsCIDR: 10.233.64.0/18
    kubeServiceCIDR: 10.233.0.0/18
  registry:
    registryMirrors: []
    insecureRegistries: []
    privateRegistry: ""
  storage:
    defaultStorageClass: localVolume
    localVolume:
      storageClassName: local  

---
apiVersion: installer.kubesphere.io/v1alpha1
kind: ClusterConfiguration
metadata:
  name: ks-installer
  namespace: kubesphere-system
  labels:
    version: v3.0.0
spec:
  local_registry: ""
  persistence:
    storageClass: ""
  authentication:
    jwtSecret: ""
  etcd:
    monitoring: true
    endpointIps: 192.168.5.141,192.168.5.142,192.168.5.143
    port: 2379
    tlsEnable: true
  common:
    es:
      elasticsearchDataVolumeSize: 20Gi
      elasticsearchMasterVolumeSize: 4Gi
      elkPrefix: logstash
      logMaxAge: 7
    mysqlVolumeSize: 20Gi
    minioVolumeSize: 20Gi
    etcdVolumeSize: 20Gi
    openldapVolumeSize: 2Gi
    redisVolumSize: 2Gi
  console:
    enableMultiLogin: false  # enable/disable multi login
    port: 30880
  alerting:
    enabled: true
  auditing:
    enabled: true
  devops:
    enabled: true
    jenkinsMemoryLim: 2Gi
    jenkinsMemoryReq: 1500Mi
    jenkinsVolumeSize: 8Gi
    jenkinsJavaOpts_Xms: 512m
    jenkinsJavaOpts_Xmx: 512m
    jenkinsJavaOpts_MaxRAM: 2g
  events:
    enabled: true
    ruler:
      enabled: true
      replicas: 2
  logging:
    enabled: true
    logsidecarReplicas: 2
  metrics_server:
    enabled: true
  monitoring:
    prometheusMemoryRequest: 400Mi
    prometheusVolumeSize: 20Gi
  multicluster:
    clusterRole: none  # host | member | none
  networkpolicy:
    enabled: true
  notification:
    enabled: true
  openpitrix:
    enabled: true
  servicemesh:
    enabled: true
```



### 卸载KubeSphere和Kubenetes

您可以通过以下命令删除群集。

> 提示
>
> ​		卸载将从计算机中删除 KubeSphere 和 Kubernetes。此操作不可逆，没有任何备份。操作时请小心。



- 如果您从快速入门开始（all-in-one安装）：

```
./kk delete cluster
```

- 如果从高级模式开始（使用配置文件创建）：

```
./kk delete cluster [-f config-sample.yaml]
```

### 升级



