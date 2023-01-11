# Keepalive+LVS负载均衡方案部署

## 1. 环境要求

| 项目     | 软件   | 版本                  |
| -------- | ------ | --------------------- |
| 操作系统 | CentOS | 7.3 及以上的 7.x 版本 |
| 基础工具 | ssh    | -                     |

## 2. 部署拓扑

**LVS Director **：主： 192.168.1.51 备：192.168.1.52

**Real Server(服务提供集群)**：192.168.1.53，192.168.1.54，192.168.1.55

**VIP**：192.168.1.200

![](./assets/LVS部署图.svg)

1. 部署采用的是DR（直连）的方式。
2. 51和52做为LVS Director，安装有keepalived，采用主备容灾。其中主节点持有VIP。
3. 53,54,55三台作为实际服务提供层，每台都持有VIP。
4. 请求过程：

- 客户端向VIP发起请求，请求会被指向到Director服务的Master节点。
- Master节点根据负载均衡算法，转发报文给其中一台Real Server。
- Real Server 发现自身持有目标的VIP，对请求进行响应，处理后直接返回给client。

## 3.安装部署

### 3.1 安装ipvsadm & keepalived

配置好yum安装环境，执行yum安装：

``` shell
yum -y install ipvsadm keepalived
```

无法配置yum安装环境，采用rpm包安装：
``` shell
rpm -i ipset-libs-7.1-1.el7.x86_64.rpm 
rpm -i ipset-7.1-1.el7.x86_64.rpm 
rpm -Uvh net-snmp-libs-5.7.2-49.el7_9.1.x86_64.rpm 
rpm -Uvh net-snmp-agent-libs-5.7.2-49.el7_9.1.x86_64.rpm 
rpm -i keepalived-1.3.5-19.el7.x86_64.rpm 
rpm -i ipvsadm-1.27-8.el7.x86_64.rpm 
```

## 3.2  Director 服务LVS配置

1. 配置文件/etc/sysctl.conf，增加以下信息

   ```properties
   # 开启数据包转发
   net.ipv4.ip_forward = 1
   # 以下两条ARP配置目的为抑制虚拟IP主机响应ARP报文，避免负载均衡失效
   # 只响应目的IP地址为接收网卡上的本地地址的arp请求
   net.ipv4.conf.all.arp_ignore = 1
   # 仅回应同网段的ARP报文
   net.ipv4.conf.all.arp_announce = 2
   # 网络数据包的最大数目
   net.core.netdev_max_backlog = 500000
   ```

   执行命令生效：

   ```bash
   sysctl -p
   ```

2. 修改并发数

   ```bash
    # 20 表示20位
    echo "options ip_vs conn_tab_bits=20" > /etc/modprobe.d/ip_vs.conf
   ```

   
## 3.3 Director 服务Keepalived配置

1. 配置/etc/keepalived/keepalived.conf

```
global_defs {                       
        router_id LVS_DEVEL # 服务器标识            
}

vrrp_instance VI_1 {            
        state MASTER     #配置LVS是主机的状态  MASTER/BACKUP      
        interface ens192     #配置LVS机器对外开放的IP       
        virtual_router_id 51   # 虚拟路由标识MASTER和BACKUP需一致     
        priority 100           # 优先级，MASTER需高于BACKUP       
        advert_int 1           # 检测时间间隔，单位是秒
        authentication {       # 设定验证类型和密码 
                auth_type PASS
                auth_pass 1111
        }

        virtual_ipaddress {         
                192.168.1.200    #设定虚拟VIP地址，每行一个
        }

}

virtual_server 192.168.1.200 80 { # 虚拟服务器定义部分，配置了3个节点
        delay_loop 6           # 设置运行情况检查，单位是秒
        lb_algo wrr            # 设置负载调度算法,wrr 加权轮询
        lb_kind DR         #使用LVS DR模式（直连,还可选NAT/TUN）                 
        nat_mask 255.255.255.0   # 设置子网掩码
        persistence_timeout 0    # 会话保持时间，单位是秒
        protocol TCP            # 指定转发协议类型              
        real_server 192.168.1.53 80 {    #真实服务的IP
                weight 1        #配置加权轮询的权重             
                TCP_CHECK {    # 节点状态监测设置                 
                        connect_timeout 10   # 连接超时时间
                        nb_get_retry 3 # 重试次数
                        delay_before_retry 3 # 重试间隔
                        connect_port 80 # 监测端口
                }

        }

        real_server 192.168.1.54 80 {
                weight 1
                TCP_CHECK {
                        connect_timeout 10
                        nb_get_retry 3
                        delay_before_retry 3
                        connect_port 80
                }

        }
        
         real_server 192.168.1.55 80 {
                weight 1
                TCP_CHECK {
                        connect_timeout 10
                        nb_get_retry 3
                        delay_before_retry 3
                        connect_port 80
                }

        }

}
```

## 3.4 Real Server配置

1. 配置文件/etc/sysctl.conf，增加以下信息

```properties
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
```

2. 配置VIP，创建文件 /etc/sysconfig/network-scripts/ifcfg-lo:0，增加一下信息

```properties
DEVICE=lo:0
# vip地址
IPADDR=192.168.1.200
NETMASK=255.255.255.255
ONBOOT=yes
NAME=loopback
```

3. 执行命令，使配置生效

```bash
# 启用vip
ifup lo:0	
# arp抑制配置生效
sysctl -p
```

## 3.5 启用LVS服务

```bash
# 清空旧的LVS
ipvsadm -C
# 重启keepalived
service keepalived restart
# 查看lvs信息
ipvsadm -Ln
# 查看到信息如下
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.1.200:80 wrr
  -> 192.168.1.53:80              Route   1      0          0         
  -> 192.168.1.54:80              Route   1      0          0         
  -> 192.168.1.55:80              Route   1      0          0 

```







