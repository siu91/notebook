# Flyway 使用规范

> By [Siu]() 2021/02/07
>
> ​		Flyway是一款数据库迁移（migration）工具。在部署应用的时候，自动执行数据库脚本，实现**数据库自动化**。Flyway 支持 SQL 和 Java 两种类型的脚本，可以将脚本打包到应用程序中，在应用程序启动时，由 Flyway 来管理这些脚本的执行，这些脚本被 Flyway 称之为 migration。
>
> 就目前而言，我们部署应用的流程大概是这样的：
>
> - 开发人员将应用程序打包、按版本整理数据库升级脚本；
> - DBA 根据数据库升级脚本检查、备份、执行，以完成数据库升级；
> - 运维人员拿到应用部署包，备份、替换，以完成应用程序升级；
>
> 引入Flyway之后的应用部署流程：
>
> - 开发人员将应用程序打包（包括数据库脚本）；
> - 应部署人员拿到应用部署包，备份、替换，即完成应用程序升；





## 1 SQL 脚本命名规范

![](./assets/Flyway_SQL文件命名规则.svg)



### **1.1 格式**

`V{version}.{date}.{num}__{type}__{description}.sql`

`U{version}.{date}.{num}__{type}__{description}.sql`

`R__{description}.sql`

> **例：**
>
> - `V5.1.0.210205.1__DDL__alter_table_user.sql`
> - `U5.1.0.210205.1__DDL__undo_alter_table_user.sql`
> - `R__alter_table_user.sql`



### 1.2 格式说明

- 前缀：

  - **V** 版本控制 ，每个文件只会被执行一次；
  - **U** 撤销，与 V 前缀**对应**的回退脚本，版本号与V一致；
  - **R** 可重复执行，当flyway检测有变化时会执行，执行顺序在所有V之后；

- Flyway 版本号

  > ​	版本号分为五段，前三段遵循[《语义化版本控制规范》]()（主版本号、子版本号、修订版本号），第四段是为**提交日期**，第五段是为了开发测试发布过程中有脚本修改时需要新建脚本。

  - `version` : [《语义化版本控制规范》]()中的主版本号、子版本号、修订版本号
  - `date`: 提交日期 210205
  - `num`: 必须为非负整型数字，当版本和日期相同时依次递增
  - `version、date、num`之间，分割符为  `.`
  - `前缀+Flyway版本号`必须**全局唯一**
  
- SQL 类型（type）：

  - DML：数据更新(插入、更新、删除)
  - DDL ：结构更新; 
  - DCL： 权限控制；
  
- 文件描述（description）: 使用小写字母，分割符为 **下划线** `_`

- 连接符：`版本号、SQL类型、文件描述`之间连接符为**双下划线** `__`

- 固定后缀 ：`.sql`




## 2 使用规范

- **禁止**修改**已执行**的 SQL 文件；

- **禁止** DDL 与 DML 语句不能写在同一  SQL 文件；

- 增加 SQL 脚本后，**必须**先在本地进行启动应用验证；

- **禁止**提交执行失败的 SQL 文件；

- SpringBoot 配置文件中必须配置 spring.flyway.table 避免同一个库不同项目的冲突；
  
  - 参考最佳实践中 flyway的配置文件
  
- **建议** DDL 中  `DROP TABLE IF EXISTS` 改为 `CREATE TABLE IF NOT EXISTS`

  - 使用数据库自动化时**删表**风险比较大

- **建议**单库多模块的项目，把 flyway 脚本和配置放在一个基础模块统一管理

- 非项目初始时引入 Flyway **必须**配置：

  ```yml
  spring:
    flyway:
      baseline-version: 2.7.0 # 基线版本为项目开始使用 flyway 的版本号
      baseline-on-migrate: true #  针对非空数据库是否默认调用基线版本,为空的话默认会调用基线版本
  ```

  



## 3 最佳实践

### 3.1 Flyway 配置

### 3.1.1 yml 配置

```yml
spring:
  flyway:
    enabled: true # 正式环境才开启
    clean-disabled: true # 禁用数据库清理
    encoding: UTF-8
    locations: classpath:/db/migration # 指定sql 脚本的路径
    # flyway 会在库中创建此名称元数据表，用于记录所有版本演化和状态
    # 同一个库不同项目可能冲突，每个项目一张表来记录
    table: fsh_uac2 #后缀指定为当前项目名称
    baseline-version: 0 # 基线版本默认开始序号 默认为 1
    baseline-on-migrate: true #  针对非空数据库是否默认调用基线版本,为空的话默认会调用基线版本
```

### 3.1.2 依赖库

```yml
		<dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
```





### 3.2 旧项目改造（非首次部署）

> ​		假设一个旧项目 `old-app` 当前版本号为 2.6.0，需要改造引入flyway。



1. 定义一个改造的需求版本，版本号为 **2.7.0** （这个版本没有其它实际需求）

2. 将表结构DDL、DML、DCL 等 sql，按上述规范整理到相应文件中：

   - `V1.0.0.{num}__{type}__oldapp_init.sql`

3. 在 {spring.flyway.locations} 下创建一个`V2.7.0__baseline.sql` 空文件，用于占位；

4. flyway 配置文件：

   ```yml
   spring:
     flyway:
       # 其它省略 ... 
       baseline-version: 2.7.0 # 基线版本为项目开始使用 flyway 的版本号
       baseline-on-migrate: true #  针对非空数据库是否默认调用基线版本
   ```

5. 发布 2.7.0 

   - 升级发布：

     - 项目启动时 flyway 会生成 {spring.flyway.table}

     - 并自动执行`V2.7.0__baseline.sql `（如果脚本非空，实际内容也不会执行）

     - 在 {spring.flyway.table} 中标记基线版本

       | installed_rank | version | description           | type     | script                | checksum | installed_by | installed_on               | execution_time | success |
       | -------------- | ------- | --------------------- | -------- | --------------------- | -------- | ------------ | -------------------------- | -------------- | ------- |
       | 1              | 2.7.0   | << Flyway Baseline >> | BASELINE | << Flyway Baseline >> |          | null         | 2021-02-24 16:05:50.632119 | 0              | t       |

   - 新环境首次部署：

     - 项目启动时 flyway 会生成 {spring.flyway.table}
     - 并自动执行以下SQL脚本：
       - `V1.0.0.{num}__{type}__oldapp_init.sql`
       - `V2.7.0__baseline.sql `

6. 之后的版本迭代（如2.8.0）

   - sql 整理：将2.8.0 版本的sql 文件按照规范整理到相应文件中：
     - `V2.8.0.{date}.{num}__{type}__{description}.sql`
   - 升级发布:
     - 项目启动时自动执行 `V2.8.0.{date}.{num}__{type}__{description}.sql`
   - 新环境首次部署：
     - 项目启动时 flyway 会生成 {spring.flyway.table}
     - 并自动执行以下SQL脚本：
       - `V1.0.0.{num}__{type}__oldapp_init.sql`
       - `V2.7.0__baseline.sql `
       - `V2.8.0.{date}.{num}__{type}__{description}.sql`





## 附录

### flyway 配置说明

```yaml
flyway.baseline-description对执行迁移时基准版本的描述.
flyway.baseline-on-migrate当迁移时发现目标schema非空，而且带有没有元数据的表时，是否自动执行基准迁移，默认false.
flyway.baseline-version开始执行基准迁移时对现有的schema的版本打标签，默认值为1.
flyway.check-location检查迁移脚本的位置是否存在，默认false.
flyway.clean-on-validation-error当发现校验错误时是否自动调用clean，默认false.
flyway.enabled是否开启flywary，默认true.
flyway.encoding设置迁移时的编码，默认UTF-8.
flyway.ignore-failed-future-migration当读取元数据表时是否忽略错误的迁移，默认false.
flyway.init-sqls当初始化好连接时要执行的SQL.
flyway.locations迁移脚本的位置，默认db/migration.
flyway.out-of-order是否允许无序的迁移，默认false.
flyway.password目标数据库的密码.
flyway.placeholder-prefix设置每个placeholder的前缀，默认${.
flyway.placeholder-replacementplaceholders是否要被替换，默认true.
flyway.placeholder-suffix设置每个placeholder的后缀，默认}.
flyway.placeholders.[placeholder name]设置placeholder的value
flyway.schemas设定需要flywary迁移的schema，大小写敏感，默认为连接默认的schema.
flyway.sql-migration-prefix迁移文件的前缀，默认为V.
flyway.sql-migration-separator迁移脚本的文件名分隔符，默认__
flyway.sql-migration-suffix迁移脚本的后缀，默认为.sql
flyway.tableflyway使用的元数据表名，默认为schema_version
flyway.target迁移时使用的目标版本，默认为latest version
flyway.url迁移时使用的JDBC URL，如果没有指定的话，将使用配置的主数据源
flyway.user迁移数据库的用户名
flyway.validate-on-migrate迁移时是否校验，默认为true.
```



### [sql-based-migrations](https://flywaydb.org/documentation/concepts/migrations#sql-based-migrations)

