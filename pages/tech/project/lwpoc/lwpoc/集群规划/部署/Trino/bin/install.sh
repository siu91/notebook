#!/usr/bin/env bash
JDK_FILE=/deploy/install/trino/package/zulu11.50.19-ca-jdk11.0.12-linux_x64.tar.gz
PKG_FILE=/deploy/install/trino/package/trino-server-360.tar.gz
TARGET_DIR=/deploy/trino
JDK_DIR=${TARGET_DIR}/jdk-11
WORK_DIR=${TARGET_DIR}/trino-server-360
ENV_FILE=${JDK_DIR}/jdk-env

if [ ! -f ${JDK_FILE} ];then
   echo 安装包${JDK_FILE} 文件不存在
   exit 1
fi

if [ ! -f ${PKG_FILE} ];then
   echo 安装包${PKG_FILE} 文件不存在
   exit 1
fi

if [ -d ${TARGET_DIR} ];then
    rm -rf ${TARGET_DIR}
fi

mkdir ${TARGET_DIR}

tar -xvf ${JDK_FILE} -C ${TARGET_DIR}
tar -xvf ${PKG_FILE} -C ${TARGET_DIR}

cd ${TARGET_DIR}
mv zulu11.50.19-ca-jdk11.0.12-linux_x64 jdk-11
