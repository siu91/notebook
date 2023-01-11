# Trino TPC-DS测试文档

## 1. 环境要求 

| 项目     | 软件            | 版本                                      |
| -------- | --------------- | ----------------------------------------- |
| 操作系统 | CentOS          | 7.3 及以上的 7.x 版本                     |
| 基础环境 | Java            | 11.0.11 以上版本，官方推荐的Azul Zulu版本 |
| 基础环境 | keepalived      | 2.0.9                                     |
| 基础要求 | Python          | 版本 2.6.x、2.7.x 或 3.x                  |
| 基础工具 | ssh             | -                                         |
| 测试工具 | trino（客户端） | 360                                       |

## 2. 测试方法

```bash
# 修改run-tpcds.sh 中的trino的server地址
vi run-tpcds.sh
# 运行测试脚本
./run-tpcds.sh
```



## 3. 测试结果

tpcds测试标准100条sql执行时间。

