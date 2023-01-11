#!/bin/bash

FLINK_DIR=/opt/flink
INSTALL_DIR=${FLINK_DIR}/flink-1.11.4
PKG_FILE=../package/flink-1.11.4-bin-scala_2.12.tgz
CONF_FILE=../config/flink-conf.yaml
if [ ! -f ${PKG_FILE} ];then
   echo 安装包${PKG_FILE} 文件不存在
   exit 1
fi

if [ -d ${INSTALL_DIR} ];then
    rm -rf ${INSTALL_DIR}
fi

tar -xvf ${PKG_FILE} -C ${FLINK_DIR}

if [ -f ${CONF_FILE} ];then
  cp  ${CONF_FILE}  ${INSTALL_DIR}/conf
fi

cd ${INSTALL_DIR}