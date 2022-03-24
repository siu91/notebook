**一.安装NTP**
**1.1.查看系统是否安装了ntp,一般默认安装ntpdate**

```shell
rpm -qa | grep ntp
```

**1.2.安装NTP**

```shell
yum install ntp ntpdate -y
```

**二.配置NTP服务**
这里配置一台ntp Server,一台ntp client

**2.1配置ntp Server**
**(1)打开配合文件**

```shell
vim /etc/ntp.conf
```

**(2)修改ntp Servert同步的时钟地址**
首先注释掉原有的server

```shell
#server 0.centos.pool.ntp.org iburst
#server 1.centos.pool.ntp.org iburst
#server 2.centos.pool.ntp.org iburst
#server 3.centos.pool.ntp.org iburst
```

**接下来有两种选择**
**第一种，读取远端的服务器时钟作为Server的时钟**

```shell
server 远端IP
```

**第二种，以本机的时钟为标准，不是127.0.0.1，而是127.127.1.0**

```shell
server 127.127.1.0
```

**(3)开启ntp server**

```shell
systemctl start ntpd
```

**(4)查看ntp server的状态**

```shell
systemctl status ntpd
```

在控制台显示的信息中，会发现使用的UDP进行通信，端口为123
**(5)查看是否同步**

```shell
[root@localhost network-scripts]# ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 localhost       .INIT.          16 l    -   64    0    0.000    0.000   0.000
```

**(6)设置开机自启动**

```shell
systemctl enable ntpd
```

**2.2配置ntp Client**
**(1)修改配置文件，配置上游的ntp server作为时钟标准，假设ntp server IP 192.168.2.1**

```shell
server 192.168.2.1
```

**(2)启动ntp服务**

```shell
systemctl start ntpd
```

**(3)设置开机启动**

```shell
systemctl enable ntpd
```

**(4)查看状态**

```shell
[root@localhost home]# ntpq -p
     remote           refid      st t when poll reach   delay   offset  jitter
==============================================================================
 *192.168.2.1    LOCAL(0)         6 u   46   64    3    0.622  -158833   0.014
```

状态说明：
\* 表示目前选择的主同步服务器，标 + 的表示有可能被用来进一步提高同步精度的次要服务器。
remote: 表示目前使用的NTP Server，这里选择的本机；
st: 即stratum阶层，值越小表示ntp serve的精准度越高；
when: 单位秒，几秒前曾做过时间同步更新的操作；
poll: 表示，每隔多少毫秒与ntp server同步一次；
reach: 已经向上层NTP服务器要求更新的次数；
delay: 网络传输过程钟延迟的时间；
offset: 时间补偿的结果；
jitter: Linux系统时间与BIOS硬件时间的差异时间

**(5)查看同步状态**

```shell
[root@localhost home]# ntpstat
synchronised to NTP server (192.168.2.1) at stratum 7
   time correct to within 20 ms
   polling server every 128 s
```

同步时间校正到20ms以为，每128秒同步一次



**本页编辑**      **[@gongshiwen](http://192.168.1.23/gongshiwen)** <img src="http://192.168.1.23/uploads/-/system/user/avatar/10/avatar.png?width=100" style="zoom:10%;" /> 