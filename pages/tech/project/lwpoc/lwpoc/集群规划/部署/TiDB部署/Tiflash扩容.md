> **注意：**
>
> 在原有 TiDB 集群上新增 TiFlash 组件需要注意：
>
> 1. 首先确认当前 TiDB 的版本支持 TiFlash，否则需要先升级 TiDB 集群至 v5.0 以上版本。
> 2. 执行 `tiup ctl: pd -u http://: config set enable-placement-rules true` 命令，以开启 PD 的 Placement Rules 功能。或通过 [pd-ctl](https://docs.pingcap.com/zh/tidb/stable/pd-control) 执行对应的命令。





```shell
tiup ctl:v5.2.0 pd -u http://dev.ti.db02:2379 config set enable-placement-rules true
```



```shell
 tiup cluster scale-out tidb-dev tiflash-scale-out.yaml  --user root -p
```





# REF

[使用 TiUP 扩容缩容 TiDB 集群 | PingCAP Docs](https://docs.pingcap.com/zh/tidb/stable/scale-tidb-using-tiup#扩容-tiflash-节点)



**本页编辑**      **[@gongshiwen](http://192.168.1.23/gongshiwen)** <img src="http://192.168.1.23/uploads/-/system/user/avatar/10/avatar.png?width=100" style="zoom:10%;" /> 