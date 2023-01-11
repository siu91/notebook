#!/bin/bash
#
# @CreationTime
#   2020/09/25 下午20:50:30
# @ModificationDate
#   2020/09/25 下午20:50:30
# @Function
#  发布
# @Usage
#   $ sh ./install_harbor.sh
#
# @author siu

# 离线安装harbor

mkdir -p /cert/harbor
chmod -R 777 /cert/harbor
# shellcheck disable=SC2164
cd /cert/harbor

# whereis openssl 检查是否有安装openssl，如果没有先安装openssl组件，如果有就不用安装了
#whereis openssl
#yum install openssl

# 创建服务器证书密钥文件harbor.key
# openssl genrsa -des3 -out harbor.key 2048
echo 'harbor' | openssl genrsa -des3 -out harbor.key 2048
# 输入密码，确认密码，自己随便定义，但是要记住，后面会用到。

# 创建服务器证书的申请文件harbor.csr
openssl req -new -key harbor.key -out harbor.csr
# 输入密钥文件的密码, 然后一路回车

# 备份一份服务器密钥文件
cp harbor.key harbor.key.org

# 去除文件口令
openssl rsa -in harbor.key.org -out harbor.key
# 输入密钥文件的密码

# 创建一个自当前日期起为期十年的证书 harbor.crt
openssl x509 -req -days 36500 -in harbor.csr -signkey harbor.key -out harbor.crt



/opt/harbor-offline-installer-v2.1.0.tgz