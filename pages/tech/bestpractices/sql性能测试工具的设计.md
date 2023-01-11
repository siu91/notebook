# sql 性能测试工具的设计

> By [Siu]() 2022/3/17



## 前言

当前的团队的工作比较多的会在关注和执行 sql 性能相关的测试，对于标准的测试模型，如 TPC 范围内的工具有比较好的实践方式，对于自定义和具体的场景目前团队还没有去总结一个比较好的”工具方案“，这里主要围绕这个问题去做一些分享。





## 先看看有哪些现有工具？

- Tidb bench ：C ；集成在 TiDB 中，用于 TPC-C/H 的测试，不适用于其它数据库
- BenchMarkSQL 5.0： Java；适用于 TPC-C ，主流的 RDBMS 都支持，Mysql/PostgreSQL/Oracle 等
- Sysbench：C；适用于 TPC-C ，主流的 RDBMS 都支持，Mysql/PostgreSQL/Oracle 等
- mysqlslap：C；用于msyql 的性能测试
- sqlbench：go；支持 PostgreSQL 的性能测试
- 其它的开源的库针对非传统数据库/组件：这些通常是依据标准模型 TPC-H/DS、SSB 等的实现，这部分较复杂，可以到官方和社区去找一些方案和工具（ClickHouse、Flink、Trino）

简单总结：

- 以上这些工具都是比较优秀的，大多是开源的；整体我都使用过，值得去深入了解各自的场景和特点；
- BenchMarkSQL、Sysbench 比较合适标准模型的基准测试（mysqlslap 也比较适合，但不主流）；
- mysqlslap、sqlbench：适用于自定义的 sql 场景的测试；



## 这些工具的“设计“

> "设计”，主要讨论这些工具的内部设计大体是怎么样的，哪些可以借鉴和指导我们去设计/开发我们的自定义 sql 性能测试工具/脚本。
>
> 当然这些我总结的”范式“可能不是真正的标准，但是已经经过了具体的借鉴和实践。

### 编程范式

当然设计会受语言的编程范式影响，受语言特性影响，但这里忽略这部分，不做讨论。

实际实现的时候要考虑这部分。



### 工具设计的拆解

分析比较了 BenchMarkSQL 5.0、sqlbench、mysqlslap 等的功能和代码，等到如下总结：

- 环境/全局配置：通过 CMD 参数或配置文件加载到程序
  - 环境：系统、依赖工具、数据库信息
  - 全局：工具运行时的参数，线程数、执行数等
- sql 任务配置：定义 sql 执行的单位
- 其它：主要是功能，造数、执行日志（参数、环境、上下文，IO，网络等）、执行结果/绘图、终端动态展示运行等

用一个命令行描述：

```shell
sh myApp --config=./config/env.conf --sql=./sql/* --func xxx
```



特别说下 BenchMarkSQL TPC-C 测试流程：

- 配置数据库信息、测试的全局信息
- 启动造数据程序：元数据、数据
- 执行测试：实时输出测试指标和日志、归档日志/结果等到测试目录
- 执行绘图程序，输出图表测试结果
- 清理数据



## 设计一个简单的 sql 性能测试程序

> 这里以 mysqlslap + shell 去设计一个 sql 性能测试脚本。
>
> ***比较好的路线是基于一些标准库用某个语言去实现，这样可定制的功能比较好控制。***

### 选型

- 语言 shell：读写文件、option、函数
- 库/工具：mysqlslap

### 设计

```shell
.
├── config
│   ├── conf # 主配置：环境、全局
│   └── jobs # sql 配置
├── output # 测试输出
│   ├── test-1 # 测试1输出
│   └── test-2 # 测试2输出
└── run.sh # 入口：加载配置/日志、归档测试结果、执行：获取jobs/执行mysqlslap、option（暂未实现）
```

**配置部分：**

<img src="assets/image-20220317111645274.png" alt="image-20220317111645274" style="zoom:80%;" />



***conf 文件：***

***`任何格式，按照需求去设计`***

```shell
# 一些全局参数
db_schema='ssb'
db_user='root'
db_port='9030'
...
```

***jobs/ :***

***`任何格式，按照需求去设计，JSON、YML、TOML 都行`***

```shell
# test 1: build-in functions
test_name='build-in'
query_sql="select length(c_address) from ssb.customer;"
pre_query="set global enable_vectorized_engine=true;set global batch_size=1024;"
...
```




### 实现

逻辑描述：

`启动`  => `加载配置/optioin传入 `  => `加载jobs`  => `LOOP：构建job > 执行job > 记录job日志&结果`  => `归档&展示测试结果`

***待实现：从 option 传入配置***

#### 运行

```shell
[root@test-fe-1 test]# sh run.sh 
=====================================================================================================================================
test-fe-1 2022-03-16 21:29:17.249 执行测试：build-in 
test-fe-1 2022-03-16 21:29:17.256 执行预处理：set global enable_vectorized_engine=true;set global batch_size=1024;
test-fe-1 2022-03-16 21:29:17.264 执行测试 SQL：select length(c_address) from ssb.customer;
test-fe-1 2022-03-16 21:29:25.877 build-in 执行完成： build-in,mixed,1.698,1.298,1.872,10,1
=====================================================================================================================================
test-fe-1 2022-03-16 21:29:25.883 执行测试：n-udf-f 
test-fe-1 2022-03-16 21:29:25.890 执行预处理：set global enable_vectorized_engine=false;
test-fe-1 2022-03-16 21:29:25.895 执行测试 SQL：select ssb.get_string_length(c_address) from ssb.customer;
test-fe-1 2022-03-16 21:29:34.986 n-udf-f 执行完成： n-udf-f,mixed,1.798,1.740,1.879,10,1
=====================================================================================================================================
test-fe-1 2022-03-16 21:29:34.995 执行测试：rudf2-t-1024 
test-fe-1 2022-03-16 21:29:35.001 执行预处理：set global enable_vectorized_engine=true;set global batch_size=1024;
test-fe-1 2022-03-16 21:29:35.008 执行测试 SQL：select ssb.str_length(c_address) from ssb.customer;
test-fe-1 2022-03-16 21:29:44.929 rudf2-t-1024 执行完成： rudf2-t-1024,mixed,1.961,1.867,2.058,10,1
=====================================================================================================================================
test-fe-1 2022-03-16 21:29:44.936 执行测试：rudf3-t-2048 
test-fe-1 2022-03-16 21:29:44.942 执行预处理：set global enable_vectorized_engine=true;set global batch_size=2048;
test-fe-1 2022-03-16 21:29:44.948 执行测试 SQL：select ssb.str_length(c_address) from ssb.customer;
test-fe-1 2022-03-16 21:29:53.113 rudf3-t-2048 执行完成： rudf3-t-2048,mixed,1.612,1.494,1.782,10,1
=====================================================================================================================================
test-fe-1 2022-03-16 21:29:53.119 执行测试：rudf4-t-4096 
test-fe-1 2022-03-16 21:29:53.124 执行预处理：set global enable_vectorized_engine=true;set global batch_size=4096;
test-fe-1 2022-03-16 21:29:53.129 执行测试 SQL：select ssb.str_length(c_address) from ssb.customer;
test-fe-1 2022-03-16 21:30:00.478 rudf4-t-4096 执行完成： rudf4-t-4096,mixed,1.447,1.396,1.518,10,1
=====================================================================================================================================
test-fe-1 2022-03-16 21:30:00.485 执行测试：rudf2-5-8192 
test-fe-1 2022-03-16 21:30:00.492 执行预处理：set global enable_vectorized_engine=true;set global batch_size=8192;
test-fe-1 2022-03-16 21:30:00.497 执行测试 SQL：select ssb.str_length(c_address) from ssb.customer;
test-fe-1 2022-03-16 21:30:07.553 rudf2-5-8192 执行完成： rudf2-5-8192,mixed,1.388,1.352,1.488,10,1
=====================================================================================================================================
test-fe-1 2022-03-16 21:30:07.561 执行测试：rudf6-t-16384 
test-fe-1 2022-03-16 21:30:07.567 执行预处理：set global enable_vectorized_engine=true;set global batch_size=16384;
test-fe-1 2022-03-16 21:30:07.574 执行测试 SQL：select ssb.str_length(c_address) from ssb.customer;
test-fe-1 2022-03-16 21:30:11.685 rudf6-t-16384 执行完成： rudf6-t-16384
##########################################################################
全局参数：
client_num=10
queries_num=10
测试结果： test-20220316212917243/result.csv 
test_name      mode   avg    min    max    client_num  queries_per_client
build-in       mixed  1.698  1.298  1.872  10          1
n-udf-f        mixed  1.798  1.740  1.879  10          1
rudf2-5-8192   mixed  1.388  1.352  1.488  10          1
rudf2-t-1024   mixed  1.961  1.867  2.058  10          1
rudf3-t-2048   mixed  1.612  1.494  1.782  10          1
rudf4-t-4096   mixed  1.447  1.396  1.518  10          1
rudf6-t-16384
#########################################################################
```







## ref

- [测试工具：BenchMarkSQL 5.0](https://sourceforge.net/projects/benchmarksql/) | [使用方法](https://support.huaweicloud.com/tstg-kunpengdbs/kunpengbenchmarksql_06_0002.html)
- [Sysbench 在美团点评中的应用](https://tech.meituan.com/2017/07/14/sysbench-meituan.html)


## 附录

### 实现的脚本

```shell
#!/bin/bash
#
# @CreationTime
#   2022/3/15 下午16:45:20
# @Function
#
# @Usage
# @author Siu

CURRENT_PATH=$(readlink -f "$(dirname "$0")")

##  region 全局参数：当有配置文件覆盖时这里的参数无效
db_ip=$(hostname -I | awk '{gsub(/^\s+|\s+$/, "");print}')
# 总查询的次数 = min(client_queries_limit,client_num * run_times)
client_num=10
run_times=5
# 官方文档说明：Limit each client to approximately this number of queries，实际限制每个 client，而是限制总查询数
client_queries_limit=10
db_schema='ssb'
db_user='root'
db_port='9030'

# 配置文件
conf_file="${CURRENT_PATH}"/config/conf
# jobs
jobs_path="${CURRENT_PATH}"/config/jobs
cmd_input=""
## endregion

## 记录日志
logFmt() {
	date_str=$(date "+%Y-%m-%d %H:%M:%S.%3N")
	echo "$(hostname -s)" "${date_str}" "$1"
	# shellcheck disable=SC2086
	echo "$(hostname -s)" "${date_str}" $1 >>"${archive_dir}"/run.log
}

log() {
	echo "$1"
	# shellcheck disable=SC2086
	echo $1 >>"${archive_dir}"/run.log
}

runMss() {
	mysqlslap -u ${db_user} -P ${db_port} -h ${db_ip} \
	--concurrency=${client_num} --iterations=${run_times} --number-of-queries=${client_queries_limit} --create-schema=${db_schema} \
	--query=./"${archive_dir}"/"$1".sql \
	--pre-query=./"${archive_dir}"/p_"$1".sql \
	--csv=./"${archive_dir}"/"$1".csv

	tmp=$(cat ./"${archive_dir}"/"$1".csv)
	tmp1=$1${tmp}
	echo "$tmp1" >./"${archive_dir}"/"$1".csv

	res=$(cat ./"${archive_dir}"/"$1".csv)

}

runJob() {
	test_name=$1
	query_sql=$2
	pre_query=$3
	echo "${query_sql}" >./"${archive_dir}"/"${test_name}".sql
	echo "${pre_query}" >./"${archive_dir}"/p_"${test_name}".sql

	log "====================================================================================================================================="
	logFmt "执行测试：${test_name} "
	logFmt "执行预处理：${pre_query}"
	logFmt "执行测试 SQL：${query_sql}"
	runMss "${test_name}"
	logFmt "$1 执行完成： ${res}"
}

runJobs() {
	if [ ! -d "${jobs_path}" ]; then
		logFmt "jobs 路径不存在：$jobs_path"
		help
		exit 1
	else
		for file in "${jobs_path}"/*; do
			if test -f $file; then
				#log "加载：$file"
				# shellcheck disable=SC1090
				. "$file"
				test_name=$(basename "$file")
				runJob "${test_name}" "${query_sql}" "${pre_query}"
			fi
			if test -d "$file"; then
				logFmt "dir:$file"
			fi
		done
	fi

}

archiveRes() {
	# 归档测试结果
	echo 'test_name,mode,avg,min,max,client_num,queries_per_client' >"${archive_dir}"/0.csv
	cat "${archive_dir}"/*.csv >"${archive_dir}"/result.csv
	rm -rf "${archive_dir}"/0.csv

	log "##########################################################################"
	log "测试结果： ${archive_dir}/result.csv "
	# shellcheck disable=SC2002
	resFmt=$(cat "${archive_dir}"/result.csv | column -t -s,)
	log "${resFmt}"
	log "#########################################################################"
}

main() {
  log "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ sql性能测试工具 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  logFmt "Options 参数：${cmd_input}"
	loadConf
	showArgs
	date_str=$(date "+%Y%m%d%H%M%S%3N")
	archive_dir=./output/test-"${date_str}"
	# 创建归档目录
	mkdir -p "${archive_dir}"
	runJobs
	archiveRes
}

showInfo() {
	echo """
  ================================================
  #                 sql 性能测试工具               #
  # 版本： 1.0.0                                 #
  # 作者： Siu                                   #
  # Support By： mysqlslap                      #
  ================================================

  """

	help
}

loadConf() {
	# shellcheck source=src/
	# 加载配置全局文件
	if [ ! -f "${conf_file}" ]; then
		logFmt "配置文件不存在将使用默认配置或命令行输入参数:${conf_file}"
	else
		. "${conf_file}"
		# shellcheck disable=SC2027
		logFmt "加载配置文件： ${conf_file}"
	fi

}

showArgs() {
	log "###############################################################################"
	log "测试参数："
	log "db_ip=${db_ip}"
	log "db_port=${db_port}"
	log "db_schema=${db_schema}"
	log "db_user=${db_user}"
	log "client_num=${client_num}"
	log "queries_limit=${client_queries_limit}"
	log "###############################################################################"

}

help() {
	echo """
Usage: ./run.sh -f ./myconfig/conf.file
       ./run.sh -j ./jobs
       ./run.sh -h  192.168.1.1
       ./run.sh -p  9001
       ./run.sh -u  admin
       ./run.sh -P  P@ssw0rd

Options:
  -f      配置文件路径，默认：./config/conf
  -j      sql 任务路径，默认：./config/jobs
  -H      数据库IP，默认：本机 IP
  -p      数据库端口，默认：9030
  -s      数据库Schema，默认：ssb
  -u      数据库用户，默认：root
  -P      数据库密码，默认：空（当前未加入Option）
  -c      测试并发数，默认：10
  -q      总查询次数，默认：10
  -h      帮助信息
  -v      工具版本信息

  """
}


#echo original parameters=[$@]

# https://www.jianshu.com/p/6393259f0a13
#-o或--options选项后面是可接受的短选项，如ab:c::，表示可接受的短选项为-a -b -c，
#其中-a选项不接参数，-b选项后必须接参数，-c选项的参数为可选的
#-l或--long选项后面是可接受的长选项，用逗号分开，冒号的意义同短选项。
#-n选项后接选项解析错误时提示的脚本名字
#ARGS=$(getopt -o ab:c:: --long along,blong:,clong:: -n "$0" -- "$@")
ARGS=$(getopt -o vhf:j:H:p:u:c:q: -n "$0" -- "$@")
if [ $? != 0 ]; then
	logFmt "参数错误，退出..."
	help
	exit 1
fi

#echo ARGS=[$ARGS]
#将规范化后的命令行参数分配至位置参数（$1,$2,...)
eval set -- "${ARGS}"
cmd_input=$(echo  formatted parameters=[$@])

while true; do
	case "$1" in
	-v)
		showInfo
		exit 0
		shift
		;;
	-h)
		help
		exit 0
		shift
		;;
	-f)
		conf_file=$2
		shift 2
		;;
	-j)
		jobs_path=$2
		shift 2
		;;
	-H)
		db_ip=$2
		shift 2
		;;
	-p)
		db_port=$2
		shift 2
		;;
	-s)
		db_schema=$2
		shift 2
		;;
	-u)
		db_user=$2
		shift 2
		;;
	-c)
		client_num=$2
		shift 2
		;;
	-q)
		#echo "option q:$2"
		client_queries_limit=$2
		shift 2
		;;
	--)
		main
		shift
		break
		;;
	*)
		help
		exit 1
		;;
	esac
done

```