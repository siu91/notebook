> 以下部署方案适合在预生产、生产环境中使用

# 准备

**主机要求[参考](./kubesphere/基于Linux安装kubesphere3多节点集群?id=step-1-准备主机)**

| Host IP       | Host Name | Role                      | 备注        |
| :------------ | :-------- | :------------------------ | ----------- |
| 192.168.5.141 | master1   | master, etcd              | 2C/8G/100G  |
| 192.168.5.142 | master2   | master, etcd              | 2C/8G/100G  |
| 192.168.5.143 | master3   | master, etcd              | 2C/8G/100G  |
| 192.168.5.145 | worker01  | worker                    | 4C/16G/100G |
| 192.168.5.146 | worker02  | worker                    | 4C/16G/100G |
| 192.168.5.147 | worker03  | worker                    | 4C/16G/100G |
| 192.168.5.148 | vip       | vip                       |             |
| 192.168.6.156 | lb-0      | lb (Keepalived + HAProxy) |             |
| 192.168.6.159 | lb-1      | lb (Keepalived + HAProxy) |             |

## 安装负载均衡器

> 以下使用**Keepalived + HAProxy**作为负载均衡器

### yum安装

```shell
yum install keepalived haproxy psmisc -y
```

### 配置HAProxy

在lb-0和lb-1上做如下配置，注意backend的服务地址：

```cfg
# HAProxy Configure /etc/haproxy/haproxy.cfg
global
    log         127.0.0.1 local2
    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon
    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats
#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    log                     global
    option                  httplog
    option                  dontlognull
    timeout connect         5000
    timeout client          5000
    timeout server          5000
#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend  kube-apiserver
    bind *:6443
    mode tcp
    option tcplog
    default_backend kube-apiserver
#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend kube-apiserver
    mode tcp
    option tcplog
    balance     roundrobin
    default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100
    server kube-apiserver-1 192.168.5.141:6443 check
    server kube-apiserver-2 192.168.5.142:6443 check
    server kube-apiserver-3 192.168.5.143:6443 check
```

### 检查配置文件语法是否正确

```shell
haproxy -f /etc/haproxy/haproxy.cfg -c
```

### 重启HAProxy和enable HAProxy

```shell
systemctl restart haproxy && systemctl enable haproxy
```

**Stop HAProxy**

```shell
systemctl stop haproxy
```

### 配置Keepalived

> 配置文件在`/etc/keepalived/keepalived.conf`

<!-- tabs:start -->

#### **主HAProxy**

> 主HAProxy 192.168.6.156

```conf
global_defs {
  notification_email {
  }
  smtp_connect_timeout 30   
  router_id LVS_DEVEL01
  vrrp_skip_check_adv_addr
  vrrp_garp_interval 0
  vrrp_gna_interval 0
}
vrrp_script chk_haproxy {
  script "killall -0 haproxy"
  interval 2
  weight 2
}
vrrp_instance haproxy-vip {
  state MASTER  
  priority 100  
  interface ens192                       
  virtual_router_id 60
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass 1111
  }
  unicast_src_ip 192.168.6.156     
  unicast_peer {
    192.168.6.159                      
  }
  virtual_ipaddress {
    #vip
    192.168.5.148/24
  }
  track_script {
    chk_haproxy
  }
}
```

#### **备HAProxy**

> 备HAProxy 192.168.6.159

```conf
global_defs {
  notification_email {
  }
  router_id LVS_DEVEL02
  vrrp_skip_check_adv_addr
  vrrp_garp_interval 0
  vrrp_gna_interval 0
}
vrrp_script chk_haproxy {
  script "killall -0 haproxy"
  interval 2
  weight 2
}
vrrp_instance haproxy-vip {
  state BACKUP
  priority 90
  interface ens192                        
  virtual_router_id 60
  advert_int 1
  authentication {
    auth_type PASS
    auth_pass 1111
  }
  unicast_src_ip 192.168.6.159      
  unicast_peer {
    192.168.6.156                        
  }
  virtual_ipaddress {
    192.168.5.148/24
  }
  track_script {
    chk_haproxy
  }
}
```

<!-- tabs:end -->

### 启动keepalived并enable keepalived

```shell
systemctl restart keepalived && systemctl enable keepalived 
```

### 验证可用性

用于查看每个磅节点的 vip 绑定状态：`ip a s`

```
ip a s
```

通过以下命令暂停 VIP 节点 HAProxy：

```
systemctl stop haproxy
```

再次使用 检查每个 lb 节点的 vip 绑定，并检查 vip 是否漂移：`ip a s`

```
ip a s
```

或者，使用下面的命令：

```
systemctl status -l keepalived
```

## 创建集群

[**参考**](./容器和k8s/kubesphere/基于Linux安装kubesphere3多节点集群?id=step-3-创建一个集群)

[**配置**](./容器和k8s/kubesphere/基于Linux安装kubesphere3多节点集群?id=安装配置ha)

```shell
./kk create cluster -f config-v1.18.6-v3-3m3w-ha.yaml
```
