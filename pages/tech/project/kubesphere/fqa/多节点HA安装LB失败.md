## 版本

**KubeSphere ：v3.0.0**

**Kubenetes ：v1.18.6**



## 问题概述

安装HA集群失败，如日志描述。[**安装详细配置**](./容器和k8s/kubesphere/基于Linux安装kubesphere3多节点集群?id=安装配置ha)

[相似问题]( https://kubesphere.com.cn/forum/d/2080-3-0/21)，这个帖子提示，可能是lb配置问题

```shell
# 两个结果不一样
curl -k https://{masterip}:6443 
curl -k https://{vip}:{lbport}
```



## 现象

**日志**

```shell
The reset process does not clean CNI configuration. To do so, you must remove /etc/cni/net.d

The reset process does not reset or clean up iptables rules or IPVS tables.
If you wish to reset iptables, you must do so manually by using the "iptables" command.

If your cluster was setup to utilize IPVS, run ipvsadm --clear (or similar)
to reset your system's IPVS tables.

The reset process does not clean your kubeconfig files and you must remove them manually.
Please, check the contents of the $HOME/.kube/config file.
```

**通过虚拟ip访问异常**

```shell
[root@master1 ~]# curl -k https://vip:6443
curl: (6) Could not resolve host: vip; Unknown error
```

> 初步定位：应该是lb配置问题或其它网络问题



## 解决

### 查看防火墙是否关闭

```shell
systemctl status firewalld.service
```

### 查看iptables是否有限制

```shell
iptables -L
```

> 发现iptable有其它业务限制了网络

**修改iptables设置或[重置iptables]([./linux/重置iptables)**，重新部署成功。

