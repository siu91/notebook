# Gitlab Issue 规范指南

> By [Siu]() 2020/05/14
>

## 1 概念定义

- 工单（Issue）：可以是一个Bug、一个建议、一个任务单
- 列表（List）：代表Issue所处不同阶段
- 看板（Board）：所有Issue 列表
- 标签（Label）：区分Issue 的处理阶段、性质、优先级

## 2 Issue 创建规范

- 标题（Titile）足够准确，能概括描述Issue的主要内容
- 描述（Description）足够清晰，包含问题的所有信息，关联信息、历史信息（使用markdown语法）；
  - 描述中话可以添加子任务`Add a task list`
- 指定接收人（Assignee），标明截止日期`Due date`
- 指定3个Label，标明`Issue 处于哪个执行/处理阶段`、标明`Issue 是何种性质`、标明`Issue 紧急程度`（参照Label 规范）
  - 优先级Label，通常由项目经理判断标明
  - 默认新提交的Issue，处理阶段都标记到`Inbox`标签
- 关联到具体的Milestone
  - 参考CR规范里面的定义

## 3 看板列表规范（List）

> 同下Label规范，执行处理阶段定义。

- Inbox，这个列表收集Issue，处于这个列表的Issue可以不指定 `Assignee`
  - **暂时只由有开发阶段的收集，需求和BUG暂未接入**
  - 每周一，由项目负责人review一遍Inbox，并作相应的指派和操作
- Todo，这个列表的Issue处于已计划阶段，需要有明确的`Assignee` 和 `Due date`
  - 由项目经理/开发负责人分配
- Doing，这个列表的Issue处于执行阶段，必须标明执行的状态`In-Progress Almost-Done  Stuck`
  - 由`Assignee`更新状态标签

## 4 标签规范（Label）

- 执行处理阶段

  - Inbox，收集阶段
  - Todo，计划阶段
  - Doing，执行阶段
    - In-Progress 进行中
    - Almost-Done 几近完成
    - Stuck 有阻碍、困难

- 性质

  - BUG 类

    - BUG-Blocker ,即系统无法执行、崩溃或严重资源不足、应用模块无法启动或异常退出、无法测试
    - BUG-Critical , 即影响系统功能或操作，主要功能存在严重缺陷，但不会影响到系统稳定性
    - BUG-Major ,即界面、性能缺陷、兼容性
    - BUG-Minor ,即易用性及建议性问题
  - PR，产品需求类

    - PR
  - Suggestion，建议类
    - SUGGESTION
  - Task，工单任务类
    - TASK

- Priority，优先级

  - HIGH **高优先级**（High）：对系统有重大影响，只有解决它之后，才能去完成其他任务。
  - MEDIUM **普通优先级**（Medium）：对系统的某个部分有影响，用户的一部分操作会达不到预期效果。
  - LOW **低优先级**（Low）：对系统的某个部分有影响，用户几乎感知不到。
  - TRIVIAL **微不足道**（Trivial）：对系统的功能没有影响，通常是视觉效果不理想，比如字体和颜色不满意。

## 5 Slack 通知集成

> 在Slack 上创建相应的channel，接收Issue 流转通知

ref <https://hugo1030.github.io/tech/slack-connect-gitlab/>
