

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;设置 Jenkins 是一个复杂的过程，因为 Jenkins 及其插件都需要一些调整和配置，需要在 Web UI 管理部分设置了许多参数：

- 凭证
- 各种插件的配置
- OAuth 配置
- cloud 配置 （dockerHost）
- jobs 和 view 
- ...



&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;在我们公司，我们尝试使用‘一切事物即代码’的模式，同样这种的模式在 Jenkins 设置上也是一种最佳的实践.Jenkins Configuration as Code ( JCasC，Jenkins 配置即代码)，"as code" 模式是指能够基于自动化管理的方式在几分钟内复制或恢复完整的 Jenkins 构建环境。

- Jenkins 变得更加稳定
- 频繁地改变 Jenkins 和任务配置
- 升级 Jenkins 及其插件
- 管理了 Jenkins 上所有的变更
- 故障发生后，可以快速的恢复 Jenkins





# Ref



[配置即代码 - Jenkins 中文社区 (jenkins-zh.cn)](https://jenkins-zh.cn/tutorial/management/plugin/configuration-as-code/)

