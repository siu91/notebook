# Copyright (c) 2020 Beijing Dingshi Zongheng Technology Co., Ltd. All rights reserved.

export HADOOP_CLASSPATH=${DORIS_HOME}/lib/hadoop/common/*:${DORIS_HOME}/lib/hadoop/common/lib/*:${DORIS_HOME}/lib/hadoop/hdfs/*:${DORIS_HOME}/lib/hadoop/hdfs/lib/*
export HADOOP_USER_NAME=${USER}

# the purpose is to use local hadoop configuration first.
# under HADOOP_CONF_DIR(eg. /etc/ecm/hadoop-conf), there are hadoop/hdfs/hbase conf files.
# and by putting HADOOP_CONF_DIR at front of HADOOP_CLASSPATH, local hadoop conf file will be searched & used first.

# local hadoop configuration is usually well-tailored and optimized, we'd better to leverage that.
# for example, if local hdfs has enabled short-circuit read, then we can use short-circuit read and save io time

# for more context, see pr: https://github.com/DorisDB/DorisDB/pull/2711

if [ ${HADOOP_CONF_DIR}"X" != "X" ]; then
    export HADOOP_CLASSPATH=${HADOOP_CONF_DIR}:${HADOOP_CLASSPATH}
fi
