# Trino部署文档

## 1. 环境要求 

| 项目     | 软件       | 版本                                      |
| -------- | ---------- | ----------------------------------------- |
| 操作系统 | CentOS     | 7.3 及以上的 7.x 版本                     |
| 基础环境 | Java       | 11.0.11 以上版本，官方推荐的Azul Zulu版本 |
| 基础环境 | keepalived | 2.0.9                                     |
| 基础要求 | Python     | 版本 2.6.x、2.7.x 或 3.x                  |
| 基础工具 | ssh        | -                                         |

**安装目录：**/deploy/trino

**端口要求：**8080（默认端口）

## 2. 安装部署

### 2.1 环境准备

1. 创建目录/deploy/trino

   ```bash
   mkdir /deploy/trino -p
   ```

2. 修改文件限制，/etc/security/limits.conf

   ```
   trino soft nofile 131072
   trino hard nofile 131072
   ```

### 2.2 安装Azul Zulu JDK11

1. 上传文件包zulu11.50.19-ca-jdk11.0.12-linux_x64.tar.gz

2. 解压文件包

   ``` bash
   tar -xvf zulu11.50.19-ca-jdk11.0.12-linux_x64.tar.gz -C /deploy/trino
   mv /deploy/trino/zulu11.50.19-ca-jdk11.0.12-linux_x64 /deploy/trino/jdk-11
   ```

### 2.3 安装trino

1. 上传文件包trino-server-360.tar.gz
2. 解压文件包

```sql
tar -xvf trino-server-360.tar.gz  -C /deploy/trino
cp trino-cli-360-executable.jar /deploy/trino/trino-server-360/trino
```

3. 修改trino的启动脚本

   ```bash
   vi /deploy/trino/trino-server-360/bin/launcher
   ```

   在执行launcher.py前增加java环境配置内容：

   ```bash
   # JDK环境配置开始
   export JAVA_HOME=/deploy/trino/jdk-11
   export CLASSPATH=.:$JAVA_HOME/lib:
   export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
   # JDK环境配置结束
   exec "$(dirname "$0")/launcher.py" "$@"
   ```

4. 创建etc目录

``` bash
cd /deploy/trino/trino-server-360
mkdir etc
```

5. 拷贝配置文件node.properties，jvm.config，config.properties
   调度节点：
   
   ```bash
   cp jvm.config etc/
   cp node.properties etc
   cp coordinator-config.properties etc/config.properties
   ```
   
   修改node.properties中的node.id，节点id需要全局唯一。
   
   工作节点：
   
   ``` bash
   cp jvm.config etc/
   cp node.properties etc
   cp worker-config.properties etc/config.properties
   ```
   
   修改node.properties中的node.id，节点id需要全局唯一。
   
   修改config.properties中的discovery.uri，填入协调节点的ip及端口
   
6. 测试trino是否能启动

``` bash
bin/launcher run
```

### 2.4 配置高可用keepalive

1. 拷贝配置keepalived.conf

   默认节点：

   ``` bash
   cp keepalived_0.conf /etc/keepalived/keepalived.conf
   cp trino_alive.sh /etc/keepalived
   ```

   副节点：

   ``` bash
   cp keepalived_1.conf /etc/keepalived/keepalived.conf
   cp trino_alive.sh /etc/keepalived
   ```

2. 修改节点信息keepalived.conf中的本机IP和虚拟IP信息。

3. 启动keepalive服务service keepalived start

## 3 安装验证

1. 浏览器http://192.168.1.181:8088/，其中192.168.1.181为虚拟ip。
2. 输入默认用户admin，密码为空。
3. 能够查看到trino的集群信息。
4. 拷贝测试postgresql.properties

```bash
cp postgresql.properties etc/catalog/
```

5. 测试数据连接

```bash
./trino --server localhost:8080 --catalog postgresql --schema default
```

6. 执行测试sql

``` sql
SHOW SCHEMAS FROM postgresql;
SHOW TABLES FROM postgresql.std_base;
select * from postgresql.std_base.std_dict; 
```



## 4 配置密码

### 4.1 生成证书

trino安全模块要求配置https的连接方式。

1. key的生成 

```javascript
openssl genrsa -des3 -out server.key 2048
```

这样是生成rsa私钥，des3算法，openssl格式，2048位强度。server.key是密钥文件名。为了生成这样的密钥，需要一个至少四位的密码。可以通过以下方法生成没有密码的key:

```javascript
openssl rsa -in server.key -out server.key
```

server.key就是没有密码的版本了。 

2. 生成CA的crt

```javascript
openssl req -new -x509 -key server.key -out ca.crt -days 3650
```

生成的ca.crt文件是用来签署下面的server.csr文件。 

3. csr的生成方法

```javascript
openssl req -new -key server.key -out server.csr
```

需要依次输入国家，地区，组织，email。最重要的是有一个common name，可以写你的名字或者域名。如果为了https申请，这个必须和域名吻合，否则会引发浏览器警报。生成的csr文件交给CA签名后形成服务端自己的证书。 

4. crt生成方法

CSR文件必须有CA的签名才可形成证书

```javascript
openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey server.key -CAcreateserial -out server.crt
```

输入key的密钥后，完成证书生成。-CA选项指明用于被签名的csr证书，-CAkey选项指明用于签名的密钥，-CAserial指明序列号文件，而-CAcreateserial指明文件不存在时自动生成。

最后生成了私用密钥：server.key和自己认证的SSL证书：server.crt

证书合并：

```javascript
cat server.key server.crt > server.pem
```

### 4.2 配置Https

配置config.properties，增加以下参数

```properties
http-server.https.enabled=true
http-server.https.port=8443
http-server.https.keystore.path=etc/server.pem
```

### 4.3 配置密码

配置config.properties，增加以下参数

```properties
http-server.authentication.type=PASSWORD
```

创建文件etc/password-authenticator.properties，增加以下内容

```properties
password-authenticator.name=file
file.password-file=/deploy/trino/trino/etc/password.db
```

创建密码文件

```bash
touch password.db
```

添加用户密码：

```bash
htpasswd -B -C 10 password.db test
```

### 4.4 连接测试

```bash
./trino --server https://{证书域名}:8443 --catalog postgresql --schema default --keystore-path etc/server.pem --user test --password
```





