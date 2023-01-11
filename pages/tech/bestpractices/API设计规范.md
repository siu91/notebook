# API 设计规范

> By Siu 2020/06/10
>
> 以下内容遵循RESTful规范的基础上，做适当的补充。



## 1 基础规范

- **1.1** 【强制】URL 中只允许包含小写字母、下划线、“/”

- **1.2**  【强制】资源的表示统一为复数名词形式；如： users，articles

- **1.3** 【强制】使用HTTP方法来表达动作（增、删、改、查）

  - 正例：

    | 动作       | API              | 备注                                          |
    | ---------- | ---------------- | --------------------------------------------- |
    | **GET**    | /users           | 获取users资源集合的URL                        |
    | **GET**    | /users/:uid      | 获取某个user资源的URL                         |
    | **POST**   | /users           | 创建一个user资源的URL                         |
    | **PUT**    | /users/:uid      | 更新一个user资源的URL                         |
    | **PUT**    | /users?uid=1,3,5 | 更新user资源的URL（**批量**，要带上限定条件） |
    | **DELETE** | /users/:uid      | 删除一个user资源的URL                         |
    | **DELETE** | /users?uid=1,3,5 | 删除user资源的URL（**批量**，要带上限定条件） |

- **1.4** 【强制】在URL中加入版本号： `/v1/users` 、`/v1/users/:uid`

  说明：

  - 如果有不兼容和破坏性的更改，版本号将让你能更容易的发布API。
  - 不需要使用次级版本号（“v1.2”），因为不应该频繁的去发布API版本。
  
- **1.5** 【强制】响应结构应包含：状态码、返回数据，返回信息（**待补充状态码**）

  - 格式统一，如下：

    ```json
    {
      "code": 0,
      "data": [],
      "message": ""
    }
    ```

  - 返回数据（data），实际返回数据要放入`data`中包装。

  - 状态码（code），参考 **[附1-状态码]()**；发生错误时，严禁返回 http 200 状态码。

  - 返回信息（message），必须是有意义的，能表明具体的业务状态和信息（特别是业务发生错误时）。

- **1.6** 【强制】列表查询的API必须分页

  - 请求参数：
    | 参数名称 | 类型 | 必须 | 备注                               |
    | :------- | ---- | :--- | :--------------------------------- |
    | page  | int  | 否   | 当前页码，默认 1                   |
    | limit    | int  | 否   | 每页条数，默认10，<=200            |

  - 返回数据：

    | 参数名称 | 类型     | 必须 | 备注             |
    | :------- | -------- | :--- | :--------------- |
    | page  | int      | 是   | 当前页码         |
    | limit    | int      | 是   | 每页条数         |
    | total    | int      | 是   | 总量             |
    | items     | object[] | 否   | 分页数据对象列表 |

- **1.7** 【强制】使用小驼峰命名法作为属性标识符。

  反例：

  ```json
  { "YearOfBirth": 1982 }
  { "year_Of_Birth": 1982 }
  ```

  正例：

  ```json
  { "yearOfBirth": 1982 }
  ```

- **1.8** 【强制】严禁下线已经发布的API，应该通过版本变更并保证客户端升级的情况下才能下线过时的API。

  说明：API的过时不是由服务端决定的，如果不能保证所有客户端都启用了新的API，就必须保持旧API的兼容。

- **1.9** 【强制】排序参数使用`sort`标识，类型 string[]，使用"-"标记**降序**。:new:

  正例：

  | API                                           | 说明                              |
  | --------------------------------------------- | --------------------------------- |
  | **GET** /v1/users?sort=-createTime            | 按照createTime降序                |
  | **GET** /v1/users?sort=-createTime,updateTime | 按照createTime降序,updateTime升序 |

  



## 2 最佳实践

- 2.1【推荐】合理设计资源多级分类（只有一个资源主题）

  例：获取某个作者的某一类文章 `GET /v1/authors/:aid/categories/:cid`。

  说明：

  - 这种 API设计不利于扩展，语义也不明确，往往要想一会，才能明白含义。
  - 多级资源使用时一定要划分清楚它们的关系，特别时还有`Query Parmas`时。

  > 推荐：**GET** /v1/authors/:aid?categories=:cid
  >
  > 设计还要考虑具体的业务，设计是服务于业务的，具体碰到的场景可以单独讨论，这只是一般规则。

- 2.2【推荐】特定资源搜索的API。

  例：模糊查询一个“姓名”、出生在某个时间之后的用户 

  > **GET** /v1/users?query=李&birth_after=1980

- 2.3【推荐】跨资源的搜索或非资源请求，可以使用动词。

  例：全局（多个资源中）搜索”siu“。

  > **GET** /v1/search?query=siu

  例：非资源请求，计算、翻译转换等。

  > **GET** /calculate?para2=23&para2=432
  >
  > **GET** /translate?from=de_DE&to=en_US&text=Hallo 

- 2.4【推荐】将 id 放在 URL 中而不是 `Query Param`

  > **GET** /v1/articles/:aid/comments ： 某篇文章的评论列表(`区别于2.1`)
  >
  > **GET** /v1/comments/:cid ： 获取
  >
  > **POST** /v1/articles/:aid/comments ： 在某篇文章中创建评论(`区别于2.1`)
  >
> **PUT** /v1/comments/:cid ： 修改评论
  >
  > **DELETE** /v1/comments/:cid ： 删除评论

- 2.5 【推荐】最短 URL 原则。

  说明：URL 用于定位资源，如果短的那个设计满足，请避免冗余的设计。

  > **GET** /v1/comments/:cid 已经可以指向一条评论了
  >
  > 就不需要再用 **GET** /v1/articles/:aid/comments/:cid特意的指出所属文章了

- 2.6 对于某些特定且复杂的业务逻辑，不要试图让客户端用复杂的查询参数表示，而是在 URL 使用别名(哪怕是动作)

  例：通过excel批量导入用户 `POST /v1/users?actions=upload`

  > 推荐 **POST** /v1/users/upload

- 2.7 超出 HTTP Method 表达语义的API。

  - 把资源的操作变成属性。
    - 例：把用户置为失效 `GET /v1/users/:uid?disabled=true`
  - 将这个操作看成某个资源的附属资源。
    - 例：Github Star gist 操作 `PUT /gists/:id/star` `DELETE /gists/:id/star` ` 

- 2.7 保持向后兼容。只要客户端能接受就通过添加字段的方式演进API，配合版本控制变更。

- 2.8 如果发现通过版本变化发布API，对客户端变化改变过大（业务不允许），允许通过 `Query Parma` 控制版本。

  说明：在实际场景中考虑业务优先的前提，允许使用通过添加参数控制版本。

  > 推荐： **GET** /v1/users?version=1

- 2.9  查询部分属性，设计一个**fields**作为过滤。:new:

  > 推荐 ：**GET** /users?**fields=id,name,address**&diabled=false

- 2.10 单独为 API 设计一个 Query Parameter 专门用于搜索，`GET /v1/users?query=keyword` :new:

- 2.11 属性编辑的接口，需要进行增量更新时，无法判定前端传递参数中置空字段和不需要更新字段

  > 推荐：参数传递时增加一个clearField字段，字段类型为List<String>告知后端哪些字段要清空



## 3 其他	

- 3.1 使用Swagger的项目 可以使用注解标记API设计者，没有使用Swagger也应该在API文档中标明。

  说明：

  - 标记API的设计者，有助于API使用者快速反馈沟通；Swagger标记方便协同。

  - Swagger 注解标记

    ```
    @Api(tags = {"标记莫格模块API作者：@作者"})
    @ApiOperation(value = "标记单个API设计者：@作者", httpMethod = "GET")
    ```

- 3.2 不使用`PATCH`，PUT 和 PATCH 都可以用于修改操作，为了统一不做区分，直接使用PUT。
- 3.3 **GET、PUT** 使用 `Query Parma` 还是 `JSON` 由业务决定设计。





# 附录

状态码

[Github API Docs](https://developer.github.com/v3/)

[Gitlab API Docs](https://docs.gitlab.com/ee/api/issues.html)

[RESTful API 设计最佳实践](https://juejin.im/entry/59e460c951882542f578f2f0)

[RESTful Service API 设计最佳工程实践和常见问题解决方案](https://www.jianshu.com/p/cf80d644727e)
