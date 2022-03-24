# Trino跨数据源级联查询验证

## tidb 和 pg

```sql
select a.installed_rank, a.version,b.* from postgresql.std_base.fsh_std a left join tidb.titpch.nation b on a.installed_rank=b.n_regionkey ;
```

```sql
-- 大表关联维表：
select a.*,b.* from postgresql.std_base.std_source a left join tidb.titpch.lineitem b on a.sort_no=b.l_linenumber ;
```



## hive 和 tidb

```sql
select a.id, a.name,b.* from hive.test.tt1 a left join tidb.titpch.nation b on a.id=b.n_regionkey ;
```

