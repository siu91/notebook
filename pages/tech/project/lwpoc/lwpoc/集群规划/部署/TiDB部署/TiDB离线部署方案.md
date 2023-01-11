# 软硬件环境要求

## Linux 操作系统版本要求

| Linux 操作系统平台       | 版本                  |
| :----------------------- | :-------------------- |
| Red Hat Enterprise Linux | 7.3 及以上的 7.x 版本 |
| CentOS                   | 7.3 及以上的 7.x 版本 |
| Oracle Enterprise Linux  | 7.3 及以上的 7.x 版本 |
| Ubuntu LTS               | 16.04 及以上的版本    |

> **注意：**
>
> - 目前尚不支持 Red Hat Enterprise Linux 8.0、CentOS 8 Stream 和 Oracle Enterprise Linux 8.0，因为目前对这些平台的测试还在进行中。
> - 不计划支持 CentOS 8 Linux，因为 CentOS 的上游支持将于 2021 年 12 月 31 日终止。
> - TiDB 将不再支持 Ubuntu 16.04。强烈建议升级到 Ubuntu 18.04 或更高版本。

其他 Linux 操作系统版本（例如 Debian Linux 和 Fedora Linux）也许可以运行 TiDB，但尚未得到 TiDB 官方支持。

## 软件配置要求

### 中控机软件配置

| 软件    | 版本         |
| :------ | :----------- |
| sshpass | 1.06 及以上  |
| TiUP    | 1.5.0 及以上 |

> **注意：**
>
> 中控机需要部署 [TiUP 软件](https://docs.pingcap.com/zh/tidb/stable/tiup-documentation-guide)来完成 TiDB 集群运维管理。

### 目标主机建议配置软件

| 软件    | 版本          |
| :------ | :------------ |
| sshpass | 1.06 及以上   |
| numa    | 2.0.12 及以上 |
| tar     | 任意          |

## 服务器建议配置

TiDB 支持部署和运行在 Intel x86-64 架构的 64 位通用硬件服务器平台或者 ARM 架构的硬件服务器平台。

服务器要求参考集群规划中的 TiDB 规划。

## 网络要求

TiDB 作为开源分布式 NewSQL 数据库，其正常运行需要网络环境提供如下的网络端口配置要求，管理员可根据实际环境中 TiDB 组件部署的方案，在网络侧和主机侧开放相关端口：

| 组件              | 默认端口 | 说明                                               |
| :---------------- | :------- | :------------------------------------------------- |
| TiDB              | 4000     | 应用及 DBA 工具访问通信端口                        |
| TiDB              | 10080    | TiDB 状态信息上报通信端口                          |
| TiKV              | 20160    | TiKV 通信端口                                      |
| TiKV              | 20180    | TiKV 状态信息上报通信端口                          |
| PD                | 2379     | 提供 TiDB 和 PD 通信端口                           |
| PD                | 2380     | PD 集群节点间通信端口                              |
| TiFlash           | 9000     | TiFlash TCP 服务端口                               |
| TiFlash           | 8123     | TiFlash HTTP 服务端口                              |
| TiFlash           | 3930     | TiFlash RAFT 服务和 Coprocessor 服务端口           |
| TiFlash           | 20170    | TiFlash Proxy 服务端口                             |
| TiFlash           | 20292    | Prometheus 拉取 TiFlash Proxy metrics 端口         |
| TiFlash           | 8234     | Prometheus 拉取 TiFlash metrics 端口               |
| Pump              | 8250     | Pump 通信端口                                      |
| Drainer           | 8249     | Drainer 通信端口                                   |
| CDC               | 8300     | CDC 通信接口                                       |
| Prometheus        | 9090     | Prometheus 服务通信端口                            |
| Node_exporter     | 9100     | TiDB 集群每个节点的系统信息上报通信端口            |
| Blackbox_exporter | 9115     | Blackbox_exporter 通信端口，用于 TiDB 集群端口监控 |
| Grafana           | 3000     | Web 监控服务对外服务和客户端(浏览器)访问端口       |
| Alertmanager      | 9093     | 告警 web 服务端口                                  |
| Alertmanager      | 9094     | 告警通信端口                                       |

## 客户端 Web 浏览器要求

TiDB 提供了基于 [Grafana](https://grafana.com/) 的技术平台，对数据库集群的各项指标进行可视化展现。采用支持 Javascript 的微软 IE、Google Chrome、Mozilla Firefox 的较新版本即可访问监控入口。



# 环境与系统配置检查

本文介绍部署 TiDB 前的环境检查操作，以下各项操作按优先级排序。

## 在 TiKV 部署目标机器上添加数据盘 EXT4 文件系统挂载参数

生产环境部署，建议使用 EXT4 类型文件系统的 NVME 类型的 SSD 磁盘存储 TiKV 数据文件。这个配置方案为最佳实施方案，其可靠性、安全性、稳定性已经在大量线上场景中得到证实。

使用 `root` 用户登录目标机器，将部署目标机器数据盘格式化成 ext4 文件系统，挂载时添加 `nodelalloc` 和 `noatime` 挂载参数。`nodelalloc` 是必选参数，否则 TiUP 安装时检测无法通过；`noatime` 是可选建议参数。

> **注意：**
>
> 如果你的数据盘已经格式化成 ext4 并挂载了磁盘，可先执行 `umount /dev/nvme0n1p1` 命令卸载，从编辑 `/etc/fstab` 文件步骤开始执行，添加挂载参数重新挂载即可。

以 `/dev/nvme0n1` 数据盘为例，具体操作步骤如下：

1. 查看数据盘。

   ```bash
   fdisk -l
   ```

   ```text
   Disk /dev/nvme0n1: 1000 GB
   ```

2. 创建分区。

   ```bash
   parted -s -a optimal /dev/nvme0n1 mklabel gpt -- mkpart primary ext4 1 -1
   ```

   > **注意：**
   >
   > 使用 `lsblk` 命令查看分区的设备号：对于 nvme 磁盘，生成的分区设备号一般为 `nvme0n1p1`；对于普通磁盘（例如 `/dev/sdb`），生成的的分区设备号一般为 `sdb1`。

3. 格式化文件系统。

   ```bash
   mkfs.ext4 /dev/nvme0n1p1
   ```

4. 查看数据盘分区 UUID。

   本例中 `nvme0n1p1` 的 UUID 为 `c51eb23b-195c-4061-92a9-3fad812cc12f`。

   ```bash
   lsblk -f
   ```

   ```text
   NAME    FSTYPE LABEL UUID                                 MOUNTPOINT
   sda
   ├─sda1  ext4         237b634b-a565-477b-8371-6dff0c41f5ab /boot
   ├─sda2  swap         f414c5c0-f823-4bb1-8fdf-e531173a72ed
   └─sda3  ext4         547909c1-398d-4696-94c6-03e43e317b60 /
   sr0
   nvme0n1
   └─nvme0n1p1 ext4         c51eb23b-195c-4061-92a9-3fad812cc12f
   ```

5. 编辑 `/etc/fstab` 文件，添加 `nodelalloc` 挂载参数。

   ```bash
   vi /etc/fstab
   ```

   ```text
   UUID=c51eb23b-195c-4061-92a9-3fad812cc12f /data1 ext4 defaults,nodelalloc,noatime 0 2
   ```

6. 挂载数据盘。

   ```bash
   mkdir /data1 && \
   mount -a
   ```

7. 执行以下命令，如果文件系统为 ext4，并且挂载参数中包含 `nodelalloc`，则表示已生效。

   ```bash
   mount -t ext4
   ```

   ```text
   /dev/nvme0n1p1 on /data1 type ext4 (rw,noatime,nodelalloc,data=ordered)
   ```

## 检测及关闭系统 swap

本段介绍 swap 关闭方法。TiDB 运行需要有足够的内存，并且不建议使用 swap 作为内存不足的缓冲，这会降低性能。因此建议永久关闭系统 swap，并且不要使用 `swapoff -a` 方式关闭，否则重启机器后该操作会失效。

建议执行以下命令关闭系统 swap：

Copy

```bash
echo "vm.swappiness = 0">> /etc/sysctl.conf
swapoff -a && swapon -a
sysctl -p
```

## 检测及关闭目标部署机器的防火墙

本段介绍如何关闭目标主机防火墙配置，因为在 TiDB 集群中，需要将节点间的访问端口打通才可以保证读写请求、数据心跳等信息的正常的传输。在普遍线上场景中，数据库到业务服务和数据库节点的网络联通都是在安全域内完成数据交互。如果没有特殊安全的要求，建议将目标节点的防火墙进行关闭。否则建议[按照端口使用规则](https://docs.pingcap.com/zh/tidb/stable/hardware-and-software-requirements#网络要求)，将端口信息配置到防火墙服务的白名单中。

1. 检查防火墙状态（以 CentOS Linux release 7.7.1908 (Core) 为例）

   ```shell
   sudo firewall-cmd --state
   sudo systemctl status firewalld.service
   ```

2. 关闭防火墙服务

   ```bash
   sudo systemctl stop firewalld.service
   ```

3. 关闭防火墙自动启动服务

   ```bash
   sudo systemctl disable firewalld.service
   ```

4. 检查防火墙状态

   ```bash
   sudo systemctl status firewalld.service
   ```

## 检测及安装 NTP 服务

TiDB 是一套分布式数据库系统，需要节点间保证时间的同步，从而确保 ACID 模型的事务线性一致性。目前解决授时的普遍方案是采用 NTP 服务，可以通过互联网中的 `pool.ntp.org` 授时服务来保证节点的时间同步，也可以使用离线环境自己搭建的 NTP 服务来解决授时。

采用如下步骤检查是否安装 NTP 服务以及与 NTP 服务器正常同步：

1. 执行以下命令，如果输出 `running` 表示 NTP 服务正在运行：

   ```bash
   sudo systemctl status ntpd.service
   ```

   ```text
   ntpd.service - Network Time Service
   Loaded: loaded (/usr/lib/systemd/system/ntpd.service; disabled; vendor preset: disabled)
   Active: active (running) since 一 2017-12-18 13:13:19 CST; 3s ago
   ```

   - 若返回报错信息 `Unit ntpd.service could not be found.`，请尝试执行以下命令，以查看与 NTP 进行时钟同步所使用的系统配置是 `chronyd` 还是 `ntpd`：

     ```bash
     sudo systemctl status cronyd.service
     ```

     ```text
     chronyd.service - NTP client/server
     Loaded: loaded (/usr/lib/systemd/system/chronyd.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2021-04-05 09:55:29 EDT; 3 days ago
     ```

     如果你使用的系统配置是 `chronyd`，请直接执行以下的步骤 3。

2. 执行 `ntpstat` 命令检测是否与 NTP 服务器同步：

   > **注意：**
   >
   > Ubuntu 系统需安装 `ntpstat` 软件包。

   ```bash
   ntpstat
   ```

   - 如果输出 `synchronised to NTP server`，表示正在与 NTP 服务器正常同步：

     ```text
     synchronised to NTP server (85.199.214.101) at stratum 2
     time correct to within 91 ms
     polling server every 1024 s
     ```

   - 以下情况表示 NTP 服务未正常同步：

     ```text
     unsynchronised
     ```

   - 以下情况表示 NTP 服务未正常运行：

     ```text
     Unable to talk to NTP daemon. Is it running?
     ```

3. 执行 `chronyc tracking` 命令查看 Chrony 服务是否与 NTP 服务器同步。

   > **注意：**
   >
   > 该操作仅适用于使用 Chrony 的系统，不适用于使用 NTPd 的系统。

   ```bash
   chronyc tracking
   ```

   - 如果该命令返回结果为 `Leap status : Normal`，则代表同步过程正常。

     ```text
     Reference ID    : 5EC69F0A (ntp1.time.nl)
     Stratum         : 2
     Ref time (UTC)  : Thu May 20 15:19:08 2021
     System time     : 0.000022151 seconds slow of NTP time
     Last offset     : -0.000041040 seconds
     RMS offset      : 0.000053422 seconds
     Frequency       : 2.286 ppm slow
     Residual freq   : -0.000 ppm
     Skew            : 0.012 ppm
     Root delay      : 0.012706812 seconds
     Root dispersion : 0.000430042 seconds
     Update interval : 1029.8 seconds
     Leap status     : Normal
     ```

   - 如果该命令返回结果如下，则表示同步过程出错：

     ```text
     Leap status    : Not synchronised
     ```

   - 如果该命令返回结果如下，则表示 Chrony 服务未正常运行：

     ```text
     506 Cannot talk to daemon
     ```

如果要使 NTP 服务尽快开始同步，执行以下命令。可以将 `pool.ntp.org` 替换为你的 NTP 服务器：

Copy

```bash
sudo systemctl stop ntpd.service && \
sudo ntpdate pool.ntp.org && \
sudo systemctl start ntpd.service
```

如果要在 CentOS 7 系统上手动安装 NTP 服务，可执行以下命令：

Copy

```bash
sudo yum install ntp ntpdate && \
sudo systemctl start ntpd.service && \
sudo systemctl enable ntpd.service
```

## 检查和配置操作系统优化参数

在生产系统的 TiDB 中，建议对操作系统进行如下的配置优化：

1. 关闭透明大页（即 Transparent Huge Pages，缩写为 THP）。数据库的内存访问模式往往是稀疏的而非连续的。当高阶内存碎片化比较严重时，分配 THP 页面会出现较高的延迟。
2. 将存储介质的 I/O 调度器设置为 noop。对于高速 SSD 存储介质，内核的 I/O 调度操作会导致性能损失。将调度器设置为 noop 后，内核不做任何操作，直接将 I/O 请求下发给硬件，以获取更好的性能。同时，noop 调度器也有较好的普适性。
3. 为调整 CPU 频率的 cpufreq 模块选用 performance 模式。将 CPU 频率固定在其支持的最高运行频率上，不进行动态调节，可获取最佳的性能。

采用如下步骤检查操作系统的当前配置，并配置系统优化参数：

1. 执行以下命令查看透明大页的开启状态。

   ```bash
   cat /sys/kernel/mm/transparent_hugepage/enabled
   ```

   ```text
   [always] madvise never
   ```

   > **注意：**
   >
   > `[always] madvise never` 表示透明大页处于启用状态，需要[关闭](https://www.huaweicloud.com/articles/cc8d2c68dd37a2b747fecb09b357f041.html)。/etc/default/grub

   ```shell
   vi /etc/default/grub
   # 修改
   GRUB_CMDLINE_LINUX="crashkernel=auto spectre_v2=retpoline rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet transparent_hugepage=never"
   # 执行生效命令
   grub2-mkconfig -o /boot/grub2/grub.cfg
   # 重启
   reboot
   ```

   

2. 执行以下命令查看数据目录所在磁盘的 I/O 调度器。假设在 sdb、sdc 两个磁盘上创建了数据目录。

   ```bash
   cat /sys/block/sd[bc]/queue/scheduler
   ```

   ```text
   noop [deadline] cfq
   noop [deadline] cfq
   ```

   > **注意：**
   >
   > `noop [deadline] cfq` 表示磁盘的 I/O 调度器使用 `deadline`，需要进行修改。

3. 执行以下命令查看磁盘的唯一标识 `ID_SERIAL`。

   ```bash
   udevadm info --name=/dev/sdb | grep ID_SERIAL
   ```

   ```text
   E: ID_SERIAL=36d0946606d79f90025f3e09a0c1f9e81
   E: ID_SERIAL_SHORT=6d0946606d79f90025f3e09a0c1f9e81
   ```

   > **注意：**
   >
   > 如果多个磁盘都分配了数据目录，需要多次执行以上命令，记录所有磁盘各自的唯一标识。

4. 执行以下命令查看 cpufreq 模块选用的节能策略。

   ```bash
   cpupower frequency-info --policy
   ```

   ```text
   analyzing CPU 0:
   current policy: frequency should be within 1.20 GHz and 3.10 GHz.
                 The governor "powersave" may decide which speed to use within this range.
   ```

   > **注意：**
   >
   > `The governor "powersave"` 表示 cpufreq 的节能策略使用 powersave，需要调整为 performance 策略。如果是虚拟机或者云主机，则不需要调整，命令输出通常为 `Unable to determine current policy`。

5. 配置系统优化参数

   - 方法一：使用 tuned（推荐）

     1. 执行 `tuned-adm list` 命令查看当前操作系统的 tuned 策略。

        ```bash
        tuned-adm list
        ```

        ```text
        Available profiles:
        - balanced                    - General non-specialized tuned profile
        - desktop                     - Optimize for the desktop use-case
        - hpc-compute                 - Optimize for HPC compute workloads
        - latency-performance         - Optimize for deterministic performance at the cost of increased power consumption
        - network-latency             - Optimize for deterministic performance at the cost of increased power consumption, focused on low latency network performance
        - network-throughput          - Optimize for streaming network throughput, generally only necessary on older CPUs or 40G+ networks
        - powersave                   - Optimize for low power consumption
        - throughput-performance      - Broadly applicable tuning that provides excellent performance across a variety of common server workloads
        - virtual-guest               - Optimize for running inside a virtual guest
        - virtual-host                - Optimize for running KVM guests
        Current active profile: balanced
        ```

        `Current active profile: balanced` 表示当前操作系统的 tuned 策略使用 balanced，建议在当前策略的基础上添加操作系统优化配置。

     2. 创建新的 tuned 策略。

        ```bash
        mkdir /etc/tuned/balanced-tidb-optimal/
        vi /etc/tuned/balanced-tidb-optimal/tuned.conf
        ```

        ```text
        [main]
        include=balanced
        
        [cpu]
        governor=performance
        
        [vm]
        transparent_hugepages=never
        
        [disk]
        devices_udev_regex=(ID_SERIAL=36d0946606d79f90025f3e09a0c1fc035)|(ID_SERIAL=36d0946606d79f90025f3e09a0c1f9e81)
        elevator=noop
        ```

        `include=balanced` 表示在现有的 balanced 策略基础上添加操作系统优化配置。

     3. 应用新的 tuned 策略。

        ```bash
        tuned-adm profile balanced-tidb-optimal
        ```

   - 方法二：使用脚本方式。如果已经使用 tuned 方法，请跳过本方法。

     1. 执行 `grubby` 命令查看默认内核版本。

        > **注意：**
        >
        > 需安装 `grubby` 软件包。

        ```bash
        grubby --default-kernel
        ```

        ```bash
        /boot/vmlinuz-3.10.0-957.el7.x86_64
        ```

     2. 执行 `grubby --update-kernel` 命令修改内核配置。

        ```bash
        grubby --args="transparent_hugepage=never" --update-kernel /boot/vmlinuz-3.10.0-957.el7.x86_64
        ```

        > **注意：**
        >
        > `--update-kernel` 后需要使用实际的默认内核版本。

     3. 执行 `grubby --info` 命令查看修改后的默认内核配置。

        ```bash
        grubby --info /boot/vmlinuz-3.10.0-957.el7.x86_64
        ```

        > **注意：**
        >
        > `--info` 后需要使用实际的默认内核版本。

        ```text
        index=0
        kernel=/boot/vmlinuz-3.10.0-957.el7.x86_64
        args="ro crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet LANG=en_US.UTF-8 transparent_hugepage=never"
        root=/dev/mapper/centos-root
        initrd=/boot/initramfs-3.10.0-957.el7.x86_64.img
        title=CentOS Linux (3.10.0-957.el7.x86_64) 7 (Core)
        ```

     4. 修改当前的内核配置立即关闭透明大页。

        ```bash
        echo never > /sys/kernel/mm/transparent_hugepage/enabled
        echo never > /sys/kernel/mm/transparent_hugepage/defrag
        ```

     5. 配置 udev 脚本应用 IO 调度器策略。

        ```bash
        vi /etc/udev/rules.d/60-tidb-schedulers.rules
        ```

        ```text
        ACTION=="add|change", SUBSYSTEM=="block", ENV{ID_SERIAL}=="36d0946606d79f90025f3e09a0c1fc035", ATTR{queue/scheduler}="noop"
        ACTION=="add|change", SUBSYSTEM=="block", ENV{ID_SERIAL}=="36d0946606d79f90025f3e09a0c1f9e81", ATTR{queue/scheduler}="noop"
        ```

     6. 应用 udev 脚本。

        ```bash
        udevadm control --reload-rules
        udevadm trigger --type=devices --action=change
        ```

     7. 创建 CPU 节能策略配置服务。

        ```bash
        cat  >> /etc/systemd/system/cpupower.service << EOF
        [Unit]
        Description=CPU performance
        [Service]
        Type=oneshot
        ExecStart=/usr/bin/cpupower frequency-set --governor performance
        [Install]
        WantedBy=multi-user.target
        EOF
        ```

     8. 应用 CPU 节能策略配置服务。

        ```bash
        systemctl daemon-reload
        systemctl enable cpupower.service
        systemctl start cpupower.service
        ```

6. 执行以下命令验证透明大页的状态。

   ```bash
   cat /sys/kernel/mm/transparent_hugepage/enabled
   ```

   ```text
   always madvise [never]
   ```

7. 执行以下命令验证数据目录所在磁盘的 I/O 调度器。

   ```bash
   cat /sys/block/sd[bc]/queue/scheduler
   ```

   ```text
   [noop] deadline cfq
   [noop] deadline cfq
   ```

8. 执行以下命令查看 cpufreq 模块选用的节能策略。

   ```bash
   cpupower frequency-info --policy
   ```

   ```text
   analyzing CPU 0:
   current policy: frequency should be within 1.20 GHz and 3.10 GHz.
                 The governor "performance" may decide which speed to use within this range.
   ```

9. 执行以下命令修改 sysctl 参数。

   ```bash
   echo "fs.file-max = 1000000">> /etc/sysctl.conf
   echo "net.core.somaxconn = 32768">> /etc/sysctl.conf
   echo "net.ipv4.tcp_tw_recycle = 0">> /etc/sysctl.conf
   echo "net.ipv4.tcp_syncookies = 0">> /etc/sysctl.conf
   echo "vm.overcommit_memory = 1">> /etc/sysctl.conf
   sysctl -p
   ```

10. 执行以下命令配置用户的 limits.conf 文件。

    ```bash
    cat << EOF >>/etc/security/limits.conf
    tidb           soft    nofile          1000000
    tidb           hard    nofile          1000000
    tidb           soft    stack          32768
    tidb           hard    stack          32768
    EOF
    ```

## 手动配置 SSH 互信及 sudo 免密码

对于有需求，通过手动配置中控机至目标节点互信的场景，可参考本段。通常推荐使用 TiUP 部署工具会自动配置 SSH 互信及免密登录，可忽略本段内容。

1. 以 `root` 用户依次登录到部署目标机器创建 `tidb` 用户并设置登录密码。

   ```bash
   useradd tidb && \
   passwd tidb
   ```

2. 执行以下命令，将 `tidb ALL=(ALL) NOPASSWD: ALL` 添加到文件末尾，即配置好 sudo 免密码。

   ```bash
   visudo
   ```

   ```text
   tidb ALL=(ALL) NOPASSWD: ALL
   ```

3. 以 `tidb` 用户登录到中控机，执行以下命令。将 `10.0.1.1` 替换成你的部署目标机器 IP，按提示输入部署目标机器 `tidb` 用户密码，执行成功后即创建好 SSH 互信，其他机器同理。新建的 `tidb` 用户下没有 `.ssh` 目录，需要执行生成 rsa 密钥的命令来生成 `.ssh` 目录。如果要在中控机上部署 TiDB 组件，需要为中控机和中控机自身配置互信。

   ```bash
   ssh-keygen -t rsa
   ssh-copy-id -i ~/.ssh/id_rsa.pub 10.0.1.1
   ```

4. 以 `tidb` 用户登录中控机，通过 `ssh` 的方式登录目标机器 IP。如果不需要输入密码并登录成功，即表示 SSH 互信配置成功。

   ```bash
   ssh 10.0.1.1
   ```

   ```text
   [tidb@10.0.1.1 ~]$
   ```

5. 以 `tidb` 用户登录到部署目标机器后，执行以下命令，不需要输入密码并切换到 `root` 用户，表示 `tidb` 用户 sudo 免密码配置成功。

   ```bash
   sudo -su root
   ```

   ```text
   [root@10.0.1.1 tidb]#
   ```

## 安装 numactl 工具

本段主要介绍如何安装 NUMA 工具。在生产环境中，因为硬件机器配置往往高于需求，为了更合理规划资源，会考虑单机多实例部署 TiDB 或者 TiKV。NUMA 绑核工具的使用，主要为了防止 CPU 资源的争抢，引发性能衰退。

> **注意：**
>
> - NUMA 绑核是用来隔离 CPU 资源的一种方法，适合高配置物理机环境部署多实例使用。
> - 通过 `tiup cluster deploy` 完成部署操作，就可以通过 `exec` 命令来进行集群级别管理工作。

1. 登录到目标节点进行安装（以 CentOS Linux release 7.7.1908 (Core) 为例）

   ```bash
   sudo yum -y install numactl
   ```

2. 通过 TiUP 的 cluster 执行完 exec 命令来完成批量安装

   ```bash
   tiup cluster exec --help
   ```

   ```text
   Run shell command on host in the tidb cluster
   
   Usage:
   cluster exec <cluster-name> [flags]
   
   Flags:
       --command string   the command run on cluster host (default "ls")
   -h, --help             help for exec
       --sudo             use root permissions (default false)
   ```

   将 tidb-test 集群所有目标主机通过 sudo 权限执行安装命令

   ```bash
   tiup cluster exec tidb-test --sudo --command "yum -y install numactl"
   ```



# 使用 TiUP 部署 TiDB 集群

[TiUP](https://github.com/pingcap/tiup) 是 TiDB 4.0 版本引入的集群运维工具，[TiUP cluster](https://github.com/pingcap/tiup/tree/master/components/cluster) 是 TiUP 提供的使用 Golang 编写的集群管理组件，通过 TiUP cluster 组件就可以进行日常的运维工作，包括部署、启动、关闭、销毁、弹性扩缩容、升级 TiDB 集群，以及管理 TiDB 集群参数。

目前 TiUP 可以支持部署 TiDB、TiFlash、TiDB Binlog、TiCDC，以及监控系统。本文将介绍不同集群拓扑的具体部署步骤。

## 第 1 步：软硬件环境需求及前置检查

[软硬件环境需求](https://docs.pingcap.com/zh/tidb/stable/hardware-and-software-requirements)

[环境与系统配置检查](https://docs.pingcap.com/zh/tidb/stable/check-before-deployment)

## 第 2 步：在中控机上安装 TiUP 组件

在中控机上安装 TiUP 组件有两种方式：在线部署和离线部署。

### 离线部署 TiUP 组件

离线部署 TiUP 组件的操作步骤如下。

#### 准备 TiUP 离线组件包

在[官方下载页面](https://pingcap.com/zh/product#SelectProduct)选择对应版本的 TiDB server 离线镜像包（包含 TiUP 离线组件包）。

#### 部署离线环境 TiUP 组件

将离线包发送到目标集群的中控机后，执行以下命令安装 TiUP 组件：

```bash
tar xzvf tidb-community-server-${version}-linux-amd64.tar.gz && \
sh tidb-community-server-${version}-linux-amd64/local_install.sh && \
source /home/tidb/.bash_profile
```

`local_install.sh` 脚本会自动执行 `tiup mirror set tidb-community-server-${version}-linux-amd64` 命令将当前镜像地址设置为 `tidb-community-server-${version}-linux-amd64`。

若需将镜像切换到其他目录，可以通过手动执行 `tiup mirror set ` 进行切换。如果需要切换到在线环境，可执行 `tiup mirror set https://tiup-mirrors.pingcap.com`。

## 第 3 步：初始化集群拓扑文件

> 使用 config/

## 第 4 步：执行部署命令

> **注意：**
>
> 通过 TiUP 进行集群部署可以使用密钥或者交互密码方式来进行安全认证：
>
> - 如果是密钥方式，可以通过 `-i` 或者 `--identity_file` 来指定密钥的路径；
> - 如果是密码方式，可以通过 `-p` 进入密码交互窗口；
> - 如果已经配置免密登录目标机，则不需填写认证。
>
> 一般情况下 TiUP 会在目标机器上创建 `topology.yaml` 中约定的用户和组，以下情况例外：
>
> - `topology.yaml` 中设置的用户名在目标机器上已存在。
> - 在命令行上使用了参数 `--skip-create-user` 明确指定跳过创建用户的步骤。

执行 deploy 命令前，先使用 `check` 及 `check --apply` 命令，检查和自动修复集群存在的潜在风险：

```shell
tiup cluster check ./topology.yaml --user root [-p] [-i /home/root/.ssh/gcp_rsa]
tiup cluster check ./topology.yaml --apply --user root [-p] [-i /home/root/.ssh/gcp_rsa]
```

然后执行 `deploy` 命令部署 TiDB 集群：

```shell
tiup cluster deploy tidb-test v5.2.0 ./topology.yaml --user root [-p] [-i /home/root/.ssh/gcp_rsa]
```

以上部署命令中：

- 通过 TiUP cluster 部署的集群名称为 `tidb-test`
- 可以通过执行 `tiup list tidb` 来查看 TiUP 支持的最新可用版本，后续内容以版本 `v5.2.0` 为例
- 初始化配置文件为 `topology.yaml`
- --user root：通过 root 用户登录到目标主机完成集群部署，该用户需要有 ssh 到目标机器的权限，并且在目标机器有 sudo 权限。也可以用其他有 ssh 和 sudo 权限的用户完成部署。
- [-i] 及 [-p]：非必选项，如果已经配置免密登录目标机，则不需填写。否则选择其一即可，[-i] 为可登录到目标机的 root 用户（或 --user 指定的其他用户）的私钥，也可使用 [-p] 交互式输入该用户的密码
- 如果需要指定在目标机创建的用户组名，可以参考[这个例子](https://github.com/pingcap/tiup/blob/master/embed/examples/cluster/topology.example.yaml#L7)。

预期日志结尾输出会有 `Deployed cluster `tidb-test` successfully` 关键词，表示部署成功。

## 第 5 步：查看 TiUP 管理的集群情况

```shell
tiup cluster list
```

TiUP 支持管理多个 TiDB 集群，该命令会输出当前通过 TiUP cluster 管理的所有集群信息，包括集群名称、部署用户、版本、密钥信息等：

```log
Starting /home/tidb/.tiup/components/cluster/v1.5.0/cluster list
Name              User  Version        Path                                                        PrivateKey
----              ----  -------        ----                                                        ----------
tidb-test         tidb  v5.2.0      /home/tidb/.tiup/storage/cluster/clusters/tidb-test         /home/tidb/.tiup/storage/cluster/clusters/tidb-test/ssh/id_rsa
```

## 第 6 步：检查部署的 TiDB 集群情况

例如，执行如下命令检查 `tidb-test` 集群情况：

```shell
tiup cluster display tidb-test
```

预期输出包括 `tidb-test` 集群中实例 ID、角色、主机、监听端口和状态（由于还未启动，所以状态为 Down/inactive）、目录信息。

## 第 7 步：启动集群

Copy

```shell
tiup cluster start tidb-test
```

预期结果输出 `Started cluster `tidb-test` successfully` 标志启动成功。

## 第 8 步：验证集群运行状态

操作步骤见[验证集群运行状态](https://docs.pingcap.com/zh/tidb/stable/post-installation-check)。

## 探索更多

如果你已同时部署了 [TiFlash](https://docs.pingcap.com/zh/tidb/stable/tiflash-overview)，接下来可参阅以下文档：

- [使用 TiFlash](https://docs.pingcap.com/zh/tidb/stable/use-tiflash)
- [TiFlash 集群运维](https://docs.pingcap.com/zh/tidb/stable/maintain-tiflash)
- [TiFlash 报警规则与处理方法](https://docs.pingcap.com/zh/tidb/stable/tiflash-alert-rules)
- [TiFlash 常见问题](https://docs.pingcap.com/zh/tidb/stable/troubleshoot-tiflash)

如果你已同时部署了 [TiCDC](https://docs.pingcap.com/zh/tidb/stable/ticdc-overview)，接下来可参阅以下文档：

- [TiCDC 任务管理](https://docs.pingcap.com/zh/tidb/stable/manage-ticdc)
- [TiCDC 常见问题](https://docs.pingcap.com/zh/tidb/stable/troubleshoot-ticdc)

> **注意：**
>
> TiDB、TiUP 及 TiDB Dashboard 默认会收集使用情况信息，并将这些信息分享给 PingCAP 用于改善产品。若要了解所收集的信息详情及如何禁用该行为，请参见[遥测](https://docs.pingcap.com/zh/tidb/stable/telemetry)。



# 附录

## 检查拓扑文件

```shell
[root@dev TiDB]# tiup cluster check ./cluster-topology-mix_v5.2_dev.yaml --user root -p
Starting component `cluster`: /root/.tiup/components/cluster/v1.5.5/tiup-cluster check ./cluster-topology-mix_v5.2_dev.yaml --user root -p
Input SSH password:
+ Download necessary tools
  - Downloading check tools for linux/amd64 ... Done
+ Collect basic system information
+ Collect basic system information
+ Collect basic system information
+ Collect basic system information
+ Collect basic system information
  - Getting system info of dev.ti.flash01:22 ... ⠸ Shell: host=dev.ti.flash01, sudo=false, command=`/tmp/tiup/bin/insight`
+ Collect basic system information
  - Getting system info of dev.ti.flash01:22 ... Done
  - Getting system info of dev.ti.flash02:22 ... Done
  - Getting system info of dev.public.mgmt01:22 ... Done
  - Getting system info of dev.ti.db01:22 ... Done
  - Getting system info of dev.ti.db02:22 ... Done
  - Getting system info of dev.ti.db03:22 ... Done






+ Check system requirements
  - Checking node dev.ti.flash01 ... ⠼ Shell: host=dev.ti.flash01, sudo=false, command=`ss -lnt`
+ Check system requirements
+ Check system requirements
+ Check system requirements
+ Check system requirements
  - Checking node dev.ti.flash01 ... ⠙ Shell: host=dev.ti.flash01, sudo=false, command=`ss -lnt`
  - Checking node dev.ti.flash02 ... ⠙ Shell: host=dev.ti.flash02, sudo=false, command=`ss -lnt`
+ Check system requirements
+ Check system requirements
+ Check system requirements
+ Check system requirements
+ Check system requirements
  - Checking node dev.ti.flash01 ... Done
  - Checking node dev.ti.flash02 ... Done
  - Checking node dev.public.mgmt01 ... Done
  - Checking node dev.ti.db01 ... Done
  - Checking node dev.ti.db02 ... Done
  - Checking node dev.ti.db03 ... Done
  - Checking node dev.ti.db01 ... Done
  - Checking node dev.ti.db02 ... Done
  - Checking node dev.ti.db03 ... Done
  - Checking node dev.ti.db01 ... Done
  - Checking node dev.ti.db02 ... Done
  - Checking node dev.ti.db03 ... Done
  - Checking node dev.public.mgmt01 ... Done
  - Checking node dev.public.mgmt01 ... Done
  - Checking node dev.public.mgmt01 ... Done
+ Cleanup check files
  - Cleanup check files on dev.ti.flash01:22 ... Done
  - Cleanup check files on dev.ti.flash02:22 ... Done
  - Cleanup check files on dev.public.mgmt01:22 ... Done
  - Cleanup check files on dev.ti.db01:22 ... Done
  - Cleanup check files on dev.ti.db02:22 ... Done
  - Cleanup check files on dev.ti.db03:22 ... Done
  - Cleanup check files on dev.ti.db01:22 ... Done
  - Cleanup check files on dev.ti.db02:22 ... Done
  - Cleanup check files on dev.ti.db03:22 ... Done
  - Cleanup check files on dev.ti.db01:22 ... Done
  - Cleanup check files on dev.ti.db02:22 ... Done
  - Cleanup check files on dev.ti.db03:22 ... Done
  - Cleanup check files on dev.public.mgmt01:22 ... Done
  - Cleanup check files on dev.public.mgmt01:22 ... Done
  - Cleanup check files on dev.public.mgmt01:22 ... Done
Node               Check       Result  Message
----               -----       ------  -------
dev.ti.flash02     os-version  Pass    OS is CentOS Linux 7 (Core) 7.6.1810
dev.ti.flash02     cpu-cores   Pass    number of CPU cores / threads: 4
dev.ti.flash02     swap        Fail    swap is enabled, please disable it for best performance
dev.ti.flash02     memory      Pass    memory size is 10240MB
dev.ti.flash02     network     Pass    network speed of ens192 is 10000MB
dev.ti.flash02     selinux     Pass    SELinux is disabled
dev.ti.flash02     thp         Pass    THP is disabled
dev.ti.flash02     command     Fail    numactl not usable, bash: numactl: command not found
dev.public.mgmt01  os-version  Pass    OS is CentOS Linux 7 (Core) 7.6.1810
dev.public.mgmt01  cpu-cores   Pass    number of CPU cores / threads: 2
dev.public.mgmt01  swap        Fail    swap is enabled, please disable it for best performance
dev.public.mgmt01  memory      Pass    memory size is 10240MB
dev.public.mgmt01  network     Pass    network speed of ens192 is 10000MB
dev.public.mgmt01  selinux     Pass    SELinux is disabled
dev.public.mgmt01  thp         Pass    THP is disabled
dev.public.mgmt01  command     Fail    numactl not usable, bash: numactl: command not found
dev.ti.db01        os-version  Pass    OS is CentOS Linux 7 (Core) 7.6.1810
dev.ti.db01        cpu-cores   Pass    number of CPU cores / threads: 2
dev.ti.db01        swap        Fail    swap is enabled, please disable it for best performance
dev.ti.db01        memory      Pass    memory size is 8192MB
dev.ti.db01        network     Pass    network speed of ens192 is 10000MB
dev.ti.db01        selinux     Pass    SELinux is disabled
dev.ti.db01        thp         Pass    THP is disabled
dev.ti.db01        command     Fail    numactl not usable, bash: numactl: command not found
dev.ti.db02        os-version  Pass    OS is CentOS Linux 7 (Core) 7.6.1810
dev.ti.db02        cpu-cores   Pass    number of CPU cores / threads: 2
dev.ti.db02        swap        Fail    swap is enabled, please disable it for best performance
dev.ti.db02        memory      Pass    memory size is 8192MB
dev.ti.db02        network     Pass    network speed of ens192 is 10000MB
dev.ti.db02        selinux     Pass    SELinux is disabled
dev.ti.db02        thp         Pass    THP is disabled
dev.ti.db02        command     Fail    numactl not usable, bash: numactl: command not found
dev.ti.db03        os-version  Pass    OS is CentOS Linux 7 (Core) 7.6.1810
dev.ti.db03        cpu-cores   Pass    number of CPU cores / threads: 2
dev.ti.db03        swap        Fail    swap is enabled, please disable it for best performance
dev.ti.db03        memory      Pass    memory size is 8192MB
dev.ti.db03        network     Pass    network speed of ens192 is 10000MB
dev.ti.db03        selinux     Pass    SELinux is disabled
dev.ti.db03        thp         Pass    THP is disabled
dev.ti.db03        command     Fail    numactl not usable, bash: numactl: command not found
dev.ti.flash01     os-version  Pass    OS is CentOS Linux 7 (Core) 7.6.1810
dev.ti.flash01     cpu-cores   Pass    number of CPU cores / threads: 4
dev.ti.flash01     swap        Fail    swap is enabled, please disable it for best performance
dev.ti.flash01     memory      Pass    memory size is 10240MB
dev.ti.flash01     network     Pass    network speed of ens192 is 10000MB
dev.ti.flash01     selinux     Pass    SELinux is disabled
dev.ti.flash01     thp         Pass    THP is disabled
dev.ti.flash01     command     Fail    numactl not usable, bash: numactl: command not found

```

## 部署集群

```shell
[root@dev TiDB]# tiup cluster deploy tidb-dev v5.2.0 cluster-topology-mix_v5.2_dev.yaml  --user root -p
Starting component `cluster`: /root/.tiup/components/cluster/v1.5.5/tiup-cluster deploy tidb-dev v5.2.0 cluster-topology-mix_v5.2_dev.yaml --user root -p
Please confirm your topology:
Cluster type:    tidb
Cluster name:    tidb-dev
Cluster version: v5.2.0
Role          Host               Ports                            OS/Arch       Directories
----          ----               -----                            -------       -----------
pd            dev.ti.db01        2379/2380                        linux/x86_64  /data3/tidb-deploy,/data3/tidb-data
pd            dev.ti.db02        2379/2380                        linux/x86_64  /data3/tidb-deploy,/data3/tidb-data
pd            dev.ti.db03        2379/2380                        linux/x86_64  /data3/tidb-deploy,/data3/tidb-data
tikv          dev.ti.db01        20160/20180                      linux/x86_64  /data1/tidb-deploy/tikv-20160,/data1/tidb-data/tikv-20160
tikv          dev.ti.db02        20160/20180                      linux/x86_64  /data1/tidb-deploy/tikv-20160,/data1/tidb-data/tikv-20160
tikv          dev.ti.db03        20160/20180                      linux/x86_64  /data1/tidb-deploy/tikv-20160,/data1/tidb-data/tikv-20160
tidb          dev.ti.db01        4000/10080                       linux/x86_64  /data2/tidb-deploy
tidb          dev.ti.db02        4000/10080                       linux/x86_64  /data2/tidb-deploy
tidb          dev.ti.db03        4000/10080                       linux/x86_64  /data2/tidb-deploy
tiflash       dev.ti.flash01     9000/8123/3930/20170/20292/8234  linux/x86_64  /data1/tidb-deploy/tiflash-9000,/data1/tidb-data/tiflash-9000
tiflash       dev.ti.flash02     9000/8123/3930/20170/20292/8234  linux/x86_64  /data1/tidb-deploy/tiflash-9000,/data1/tidb-data/tiflash-9000
cdc           dev.public.mgmt01  8300                             linux/x86_64  /data1/tidb-deploy/cdc-8300,/data1/tidb-data/cdc-8300
prometheus    dev.public.mgmt01  9090                             linux/x86_64  /data1/tidb-deploy/prometheus-9090,/data1/tidb-data/prometheus-9090
grafana       dev.public.mgmt01  3000                             linux/x86_64  /data1/tidb-deploy/grafana-3000
alertmanager  dev.public.mgmt01  9093/9094                        linux/x86_64  /data1/tidb-deploy/alertmanager-9093,/data1/tidb-data/alertmanager-9093
Attention:
    1. If the topology is not what you expected, check your yaml file.
    2. Please confirm there is no port/directory conflicts in same host.
Do you want to continue? [y/N]: (default=N) y
Input SSH password:
+ Generate SSH keys ... Done
+ Download TiDB components
  - Download pd:v5.2.0 (linux/amd64) ... Done
  - Download tikv:v5.2.0 (linux/amd64) ... Done
  - Download tidb:v5.2.0 (linux/amd64) ... Done
  - Download tiflash:v5.2.0 (linux/amd64) ... Done
  - Download cdc:v5.2.0 (linux/amd64) ... Done
  - Download prometheus:v5.2.0 (linux/amd64) ... Done
  - Download grafana:v5.2.0 (linux/amd64) ... Done
  - Download alertmanager: (linux/amd64) ... Done
  - Download node_exporter: (linux/amd64) ... Done
  - Download blackbox_exporter: (linux/amd64) ... Done
+ Initialize target host environments
  - Prepare dev.ti.db01:22 ... Done
  - Prepare dev.ti.db02:22 ... Done
  - Prepare dev.ti.db03:22 ... Done
  - Prepare dev.ti.flash01:22 ... Done
  - Prepare dev.ti.flash02:22 ... Done
  - Prepare dev.public.mgmt01:22 ... Done
+ Copy files
  - Copy pd -> dev.ti.db01 ... Done
  - Copy pd -> dev.ti.db02 ... Done
  - Copy pd -> dev.ti.db03 ... Done
  - Copy tikv -> dev.ti.db01 ... Done
  - Copy tikv -> dev.ti.db02 ... Done
  - Copy tikv -> dev.ti.db03 ... Done
  - Copy tidb -> dev.ti.db01 ... Done
  - Copy tidb -> dev.ti.db02 ... Done
  - Copy tidb -> dev.ti.db03 ... Done
  - Copy tiflash -> dev.ti.flash01 ... Done
  - Copy tiflash -> dev.ti.flash02 ... Done
  - Copy cdc -> dev.public.mgmt01 ... Done
  - Copy prometheus -> dev.public.mgmt01 ... Done
  - Copy grafana -> dev.public.mgmt01 ... Done
  - Copy alertmanager -> dev.public.mgmt01 ... Done
  - Copy node_exporter -> dev.ti.flash01 ... Done
  - Copy node_exporter -> dev.ti.flash02 ... Done
  - Copy node_exporter -> dev.public.mgmt01 ... Done
  - Copy node_exporter -> dev.ti.db01 ... Done
  - Copy node_exporter -> dev.ti.db02 ... Done
  - Copy node_exporter -> dev.ti.db03 ... Done
  - Copy blackbox_exporter -> dev.public.mgmt01 ... Done
  - Copy blackbox_exporter -> dev.ti.db01 ... Done
  - Copy blackbox_exporter -> dev.ti.db02 ... Done
  - Copy blackbox_exporter -> dev.ti.db03 ... Done
  - Copy blackbox_exporter -> dev.ti.flash01 ... Done
  - Copy blackbox_exporter -> dev.ti.flash02 ... Done
Enabling component pd
        Enabling instance dev.ti.db03:2379
        Enabling instance dev.ti.db02:2379
        Enabling instance dev.ti.db01:2379
        Enable instance dev.ti.db02:2379 success
        Enable instance dev.ti.db03:2379 success
        Enable instance dev.ti.db01:2379 success
Enabling component tikv
        Enabling instance dev.ti.db03:20160
        Enabling instance dev.ti.db01:20160
        Enabling instance dev.ti.db02:20160
        Enable instance dev.ti.db03:20160 success
        Enable instance dev.ti.db02:20160 success
        Enable instance dev.ti.db01:20160 success
Enabling component tidb
        Enabling instance dev.ti.db03:4000
        Enabling instance dev.ti.db01:4000
        Enabling instance dev.ti.db02:4000
        Enable instance dev.ti.db02:4000 success
        Enable instance dev.ti.db03:4000 success
        Enable instance dev.ti.db01:4000 success
Enabling component tiflash
        Enabling instance dev.ti.flash02:9000
        Enabling instance dev.ti.flash01:9000
        Enable instance dev.ti.flash02:9000 success
        Enable instance dev.ti.flash01:9000 success
Enabling component cdc
        Enabling instance dev.public.mgmt01:8300
        Enable instance dev.public.mgmt01:8300 success
Enabling component prometheus
        Enabling instance dev.public.mgmt01:9090
        Enable instance dev.public.mgmt01:9090 success
Enabling component grafana
        Enabling instance dev.public.mgmt01:3000
        Enable instance dev.public.mgmt01:3000 success
Enabling component alertmanager
        Enabling instance dev.public.mgmt01:9093
        Enable instance dev.public.mgmt01:9093 success
Enabling component node_exporter
        Enabling instance dev.ti.flash02
        Enabling instance dev.ti.db02
        Enabling instance dev.public.mgmt01
        Enabling instance dev.ti.db03
        Enabling instance dev.ti.db01
        Enabling instance dev.ti.flash01
        Enable dev.ti.flash02 success
        Enable dev.ti.flash01 success
        Enable dev.public.mgmt01 success
        Enable dev.ti.db03 success
        Enable dev.ti.db02 success
        Enable dev.ti.db01 success
Enabling component blackbox_exporter
        Enabling instance dev.ti.flash02
        Enabling instance dev.public.mgmt01
        Enabling instance dev.ti.db01
        Enabling instance dev.ti.db02
        Enabling instance dev.ti.db03
        Enabling instance dev.ti.flash01
        Enable dev.ti.flash02 success
        Enable dev.ti.flash01 success
        Enable dev.ti.db02 success
        Enable dev.ti.db03 success
        Enable dev.public.mgmt01 success
        Enable dev.ti.db01 success
Cluster `tidb-dev` deployed successfully, you can start it with command: `tiup cluster start tidb-dev`
```

## 查看&启动集群

```shell
[root@dev TiDB]# tiup cluster list
Starting component `cluster`: /root/.tiup/components/cluster/v1.5.5/tiup-cluster list
Name      User  Version  Path                                           PrivateKey
----      ----  -------  ----                                           ----------
tidb-dev  tidb  v5.2.0   /root/.tiup/storage/cluster/clusters/tidb-dev  /root/.tiup/storage/cluster/clusters/tidb-dev/ssh/id_rsa
[root@dev TiDB]# tiup cluster display tidb-dev
Starting component `cluster`: /root/.tiup/components/cluster/v1.5.5/tiup-cluster display tidb-dev
Cluster type:       tidb
Cluster name:       tidb-dev
Cluster version:    v5.2.0
Deploy user:        tidb
SSH type:           builtin
ID                      Role          Host               Ports                            OS/Arch       Status  Data Dir                            Deploy Dir
--                      ----          ----               -----                            -------       ------  --------                            ----------
dev.public.mgmt01:9093  alertmanager  dev.public.mgmt01  9093/9094                        linux/x86_64  Down    /data1/tidb-data/alertmanager-9093  /data1/tidb-deploy/alertmanager-9093
dev.public.mgmt01:8300  cdc           dev.public.mgmt01  8300                             linux/x86_64  Down    /data1/tidb-data/cdc-8300           /data1/tidb-deploy/cdc-8300
dev.public.mgmt01:3000  grafana       dev.public.mgmt01  3000                             linux/x86_64  Down    -                                   /data1/tidb-deploy/grafana-3000
dev.ti.db01:2379        pd            dev.ti.db01        2379/2380                        linux/x86_64  Down    /data3/tidb-data                    /data3/tidb-deploy
dev.ti.db02:2379        pd            dev.ti.db02        2379/2380                        linux/x86_64  Down    /data3/tidb-data                    /data3/tidb-deploy
dev.ti.db03:2379        pd            dev.ti.db03        2379/2380                        linux/x86_64  Down    /data3/tidb-data                    /data3/tidb-deploy
dev.public.mgmt01:9090  prometheus    dev.public.mgmt01  9090                             linux/x86_64  Down    /data1/tidb-data/prometheus-9090    /data1/tidb-deploy/prometheus-9090
dev.ti.db01:4000        tidb          dev.ti.db01        4000/10080                       linux/x86_64  Down    -                                   /data2/tidb-deploy
dev.ti.db02:4000        tidb          dev.ti.db02        4000/10080                       linux/x86_64  Down    -                                   /data2/tidb-deploy
dev.ti.db03:4000        tidb          dev.ti.db03        4000/10080                       linux/x86_64  Down    -                                   /data2/tidb-deploy
dev.ti.flash01:9000     tiflash       dev.ti.flash01     9000/8123/3930/20170/20292/8234  linux/x86_64  N/A     /data1/tidb-data/tiflash-9000       /data1/tidb-deploy/tiflash-9000
dev.ti.flash02:9000     tiflash       dev.ti.flash02     9000/8123/3930/20170/20292/8234  linux/x86_64  N/A     /data1/tidb-data/tiflash-9000       /data1/tidb-deploy/tiflash-9000
dev.ti.db01:20160       tikv          dev.ti.db01        20160/20180                      linux/x86_64  N/A     /data1/tidb-data/tikv-20160         /data1/tidb-deploy/tikv-20160
dev.ti.db02:20160       tikv          dev.ti.db02        20160/20180                      linux/x86_64  N/A     /data1/tidb-data/tikv-20160         /data1/tidb-deploy/tikv-20160
dev.ti.db03:20160       tikv          dev.ti.db03        20160/20180                      linux/x86_64  N/A     /data1/tidb-data/tikv-20160         /data1/tidb-deploy/tikv-20160
Total nodes: 15
[root@dev TiDB]# tiup cluster start tidb-dev
Starting component `cluster`: /root/.tiup/components/cluster/v1.5.5/tiup-cluster start tidb-dev
Starting cluster tidb-dev...
+ [ Serial ] - SSHKeySet: privateKey=/root/.tiup/storage/cluster/clusters/tidb-dev/ssh/id_rsa, publicKey=/root/.tiup/storage/cluster/clusters/tidb-dev/ssh/id_rsa.pub
+ [Parallel] - UserSSH: user=tidb, host=dev.public.mgmt01
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db03
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db01
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db01
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db02
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db02
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.flash01
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db03
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db01
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db02
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.flash02
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db03
+ [Parallel] - UserSSH: user=tidb, host=dev.public.mgmt01
+ [Parallel] - UserSSH: user=tidb, host=dev.public.mgmt01
+ [Parallel] - UserSSH: user=tidb, host=dev.public.mgmt01
+ [ Serial ] - StartCluster
Starting component pd
        Starting instance dev.ti.db03:2379
        Starting instance dev.ti.db01:2379
        Starting instance dev.ti.db02:2379
        Start instance dev.ti.db02:2379 success
        Start instance dev.ti.db03:2379 success
        Start instance dev.ti.db01:2379 success
Starting component tikv
        Starting instance dev.ti.db03:20160
        Starting instance dev.ti.db01:20160
        Starting instance dev.ti.db02:20160
        Start instance dev.ti.db02:20160 success
        Start instance dev.ti.db01:20160 success
        Start instance dev.ti.db03:20160 success
Starting component tidb
        Starting instance dev.ti.db03:4000
        Starting instance dev.ti.db01:4000
        Starting instance dev.ti.db02:4000
        Start instance dev.ti.db01:4000 success
        Start instance dev.ti.db03:4000 success
        Start instance dev.ti.db02:4000 success
Starting component tiflash
        Starting instance dev.ti.flash01:9000
        Starting instance dev.ti.flash02:9000
        Start instance dev.ti.flash02:9000 success
        Start instance dev.ti.flash01:9000 success
Starting component cdc
        Starting instance dev.public.mgmt01:8300
        Start instance dev.public.mgmt01:8300 success
Starting component prometheus
        Starting instance dev.public.mgmt01:9090
        Start instance dev.public.mgmt01:9090 success
Starting component grafana
        Starting instance dev.public.mgmt01:3000
        Start instance dev.public.mgmt01:3000 success
Starting component alertmanager
        Starting instance dev.public.mgmt01:9093
        Start instance dev.public.mgmt01:9093 success
Starting component node_exporter
        Starting instance dev.ti.db03
        Starting instance dev.public.mgmt01
        Starting instance dev.ti.flash01
        Starting instance dev.ti.db01
        Starting instance dev.ti.flash02
        Starting instance dev.ti.db02
        Start dev.ti.flash02 success
        Start dev.ti.db02 success
        Start dev.ti.db01 success
        Start dev.ti.flash01 success
        Start dev.ti.db03 success
        Start dev.public.mgmt01 success
Starting component blackbox_exporter
        Starting instance dev.ti.db03
        Starting instance dev.public.mgmt01
        Starting instance dev.ti.flash01
        Starting instance dev.ti.db01
        Starting instance dev.ti.flash02
        Starting instance dev.ti.db02
        Start dev.ti.db02 success
        Start dev.ti.flash02 success
        Start dev.ti.db03 success
        Start dev.ti.db01 success
        Start dev.ti.flash01 success
        Start dev.public.mgmt01 success
+ [ Serial ] - UpdateTopology: cluster=tidb-dev
Started cluster `tidb-dev` successfully
```

## 关闭集群

```shell
[root@dev TiDB]# tiup cluster stop tidb-dev
Starting component `cluster`: /root/.tiup/components/cluster/v1.5.5/tiup-cluster stop tidb-dev
Will stop the cluster tidb-dev with nodes: , roles: .
Do you want to continue? [y/N]:(default=N) y
+ [ Serial ] - SSHKeySet: privateKey=/root/.tiup/storage/cluster/clusters/tidb-dev/ssh/id_rsa, publicKey=/root/.tiup/storage/cluster/clusters/tidb-dev/ssh/id_rsa.pub
+ [Parallel] - UserSSH: user=tidb, host=dev.public.mgmt01
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db01
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db02
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db01
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db03
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db02
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db03
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.flash01
+ [Parallel] - UserSSH: user=tidb, host=dev.public.mgmt01
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db03
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.flash02
+ [Parallel] - UserSSH: user=tidb, host=dev.public.mgmt01
+ [Parallel] - UserSSH: user=tidb, host=dev.public.mgmt01
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db02
+ [Parallel] - UserSSH: user=tidb, host=dev.ti.db01
+ [ Serial ] - StopCluster
Stopping component alertmanager
        Stopping instance dev.public.mgmt01
        Stop alertmanager dev.public.mgmt01:9093 success
Stopping component grafana
        Stopping instance dev.public.mgmt01
        Stop grafana dev.public.mgmt01:3000 success
Stopping component prometheus
        Stopping instance dev.public.mgmt01
        Stop prometheus dev.public.mgmt01:9090 success
Stopping component cdc
        Stopping instance dev.public.mgmt01
        Stop cdc dev.public.mgmt01:8300 success
Stopping component tiflash
        Stopping instance dev.ti.flash02
        Stopping instance dev.ti.flash01
        Stop tiflash dev.ti.flash01:9000 success
        Stop tiflash dev.ti.flash02:9000 success
Stopping component tidb
        Stopping instance dev.ti.db03
        Stopping instance dev.ti.db01
        Stopping instance dev.ti.db02
        Stop tidb dev.ti.db01:4000 success
        Stop tidb dev.ti.db03:4000 success
        Stop tidb dev.ti.db02:4000 success
Stopping component tikv
        Stopping instance dev.ti.db03
        Stopping instance dev.ti.db01
        Stopping instance dev.ti.db02
        Stop tikv dev.ti.db03:20160 success
        Stop tikv dev.ti.db01:20160 success
        Stop tikv dev.ti.db02:20160 success
Stopping component pd
        Stopping instance dev.ti.db03
        Stopping instance dev.ti.db01
        Stopping instance dev.ti.db02
        Stop pd dev.ti.db02:2379 success
        Stop pd dev.ti.db01:2379 success
        Stop pd dev.ti.db03:2379 success
Stopping component node_exporter
        Stopping instance dev.ti.flash02
        Stopping instance dev.ti.db02
        Stopping instance dev.ti.db03
        Stopping instance dev.public.mgmt01
        Stopping instance dev.ti.flash01
        Stopping instance dev.ti.db01
        Stop dev.ti.flash02 success
        Stop dev.ti.flash01 success
        Stop dev.ti.db03 success
        Stop dev.ti.db01 success
        Stop dev.ti.db02 success
        Stop dev.public.mgmt01 success
Stopping component blackbox_exporter
        Stopping instance dev.ti.flash02
        Stopping instance dev.ti.db02
        Stopping instance dev.public.mgmt01
        Stopping instance dev.ti.db03
        Stopping instance dev.ti.db01
        Stopping instance dev.ti.flash01
        Stop dev.ti.flash01 success
        Stop dev.ti.db03 success
        Stop dev.ti.flash02 success
        Stop dev.ti.db01 success
        Stop dev.ti.db02 success
        Stop dev.public.mgmt01 success
Stopped cluster `tidb-dev` successfully
```

## 销毁集群

```shell
tiup cluster destory ${cluster-name} 
```



# REF

- [TiDB 配置参数 | PingCAP Docs](https://docs.pingcap.com/zh/tidb/stable/command-line-flags-for-tidb-configuration)
- [TiDB 配置文件描述 | PingCAP Docs](https://docs.pingcap.com/zh/tidb/stable/tidb-configuration-file)
- [centos7 编译加载toa模块_biaogou2596的博客-CSDN博客](https://blog.csdn.net/biaogou2596/article/details/100957788)
- [TiKV 线程池性能调优 | PingCAP Docs](https://docs.pingcap.com/zh/tidb/stable/tune-tikv-thread-performance)
- [提高 TiDB Dashboard 安全性：用户密码设置 | PingCAP Docs](https://docs.pingcap.com/zh/tidb/stable/dashboard-ops-security#为-tidb-root-用户设置强密码)



**本页编辑**      **[@gongshiwen](http://192.168.1.23/gongshiwen)** <img src="http://192.168.1.23/uploads/-/system/user/avatar/10/avatar.png?width=100" style="zoom:10%;" /> 