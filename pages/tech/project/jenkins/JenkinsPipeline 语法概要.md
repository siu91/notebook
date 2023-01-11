## JenkinsPipeline 语法概要



> ​		Pipeline是一套运行于jenkins上的工作流框架，将原本独立运行于单个或者多个节点的任务连接起来，实现单个任务难以完成的复杂流程编排与可视化。Pipeline通过Domain Specific Language(DSL)syntax定义Pipeline As Code并且实现持续交付的目的。

## 1、基本概念

`pipeline`的代码定义了整个构建过程，通常包括构建应用程序，测试然后交付应用程序的阶段，下面是`pipeline`语法中的基本概念：

- Stage 一个`pipeline`可以划分成若干个`stage`，每个`stage`代表一组操作，例如`build`、`deploy`。注意，`stage`是一个逻辑分组的概念，可以跨多个`node`或`agent`
- Node 一个`node`就是一个`jenkins`节点，或者是`master`，或者是`agent`，是执行`step`的具体运行环境
- Step`step`是最基本的操作单元，小到创建一个目录，大到构建一个`docker`镜像，由各类`jenkins plugin`提供，例如`sh make`

## 2、脚本式和声明式流水线

声明式`Pipeline`是`Jenkins Pipeline`的一个相对较新的补充，它在`Pipeline`子系统之上提出了一种更为简化和有意义的语法，包括：

- 提供比`Scripted Pipeline`语法更丰富的语法功能
- 声明式`Pipeline`代码更容易编写和理解

所有有效的声明性`Pipeline`必须包含在一个`pipeline`块内，例如：

```
pipeline {    /* insert Declarative Pipeline here */}
```

## 3、声明式pipeline语法

### 3.1 agent

`agent`部分指定整个`Pipeline`或特定阶段将在`Jenkins`环境中执行的位置，具体取决于该`agent` 部分的放置位置。该部分必须在`pipeline`块内的顶层定义 ，但阶段级使用是可选的。

**参数**

为了支持`Pipeline`可能拥有的各种用例，该`agent`部分支持几种不同类型的参数。这些参数可以应用于`pipeline`块的顶层，也可以应用在每个`stage`指令内。

- any 在任何可用的代理上执行`Pipeline`。例如：`agent any`
- none 当在`pipeline`块的顶层应用时，将不会为整个`Pipeline`运行分配全局代理，并且每个`stage`部分将需要包含其自己的`agent`部分。例如：`agent none`
- label 使用提供的标签在`Jenkins`环境中可用的代理上执行`Pipeline`或阶段性执行。例如：`agent { label 'my-defined-label' }`
- node`agent { node { label 'labelName' } }`行为相同`agent { label 'labelName' }`，但`node`允许其他选项（如`customWorkspace`）
- docker 执行`Pipeline`，或阶段执行，用给定的容器将被动态地供应一个节点预先配置成接受基于`Docker-based Pipelines`，或匹配的任选定义的节点上`label`的参数。`docker`还可以接受一个`args`可能包含直接传递给`docker run`调用的参数的参数。例如：`agent { docker 'maven:3-alpine' }`或

```
agent {   
	docker {        
		image 'maven:3-alpine'        
		label 'my-defined-label'        
		args  '-v /tmp:/tmp'    
		}
 }
```

- dockerfile 使用从`Dockerfile`源存储库中包含的容器构建容器来执行`Pipeline`或阶段性执行 。为了使用此选项，`Jenkinsfile`必须从多分支`Pipeline`或`Pipeline`从`SCM`加载。通常这是`Dockerfile`源库的根源：`agent { dockerfile true }`。如果`Dockerfile`在另一个目录中建立，请使用以下`dir`选项：`agent { dockerfile { dir 'someSubDir' } }`。您可以使用`docker build …`在该`additionalBuildArgs`选项将其他参数传递给命令，如`agent { dockerfile { additionalBuildArgs '--build-arg foo=bar' } }`

**常用选项**

这些是可以应用两个或多个`agent`实现的几个选项。除非明确说明，否则不需要

- label 一个字符串。运行`Pipeline`或个人的标签`stage`。此选项对于`node`，`docker`和`dockerfile`，并且是必需的`node`。
- customWorkspace 一个字符串。运行`Pipeline`或个人`stage`这`agent`是这个自定义的工作空间内的应用，而不是默认的。它可以是相对路径，在这种情况下，自定义工作区将位于节点上的工作空间根目录下，也可以是绝对路径。例如：

```
agent {    node {        label 'my-defined-label'        customWorkspace '/some/other/path'    }}
```

此选项是有效的`node`，`docker`和`dockerfile`。

- reuseNode 一个布尔值，默认为`false`。如果为`true`，则在同一工作空间中，而不是完全在新节点上运行`Pipeline`顶层指定的节点上的容器。此选项适用于`docker`和`dockerfile`，并且仅在`agent`个人使用时才有效果。例如：

```
Jenkinsfile (Declarative Pipeline)pipeline {    agent { docker 'maven:3-alpine' }     stages {        stage('Example Build') {            steps {                sh 'mvn -B clean verify'            }        }    }}
```

在给定名称和tag（`maven:3-alpine`）的新创建的容器中执行此`Pipeline`中定义的所有步骤。Stage-level `agent` 部分

```
Jenkinsfile (Declarative Pipeline)pipeline {    agent none     stages {        stage('Example Build') {            agent { docker 'maven:3-alpine' }             steps {                echo 'Hello, Maven'                sh 'mvn --version'            }        }        stage('Example Test') {            agent { docker 'openjdk:8-jre' }             steps {                echo 'Hello, JDK'                sh 'java -version'            }        }    }}
```

### 3.2 post

该`post`部分定义将在`Pipeline`运行或阶段结束时运行的操作。一些条件后 的块的内支持`post`：部分 `always`，`changed`，`failure`，`success`，`unstable`，和`aborted`。这些块允许在`Pipeline`运行或阶段结束时执行步骤，具体取决于`Pipeline`的状态。

**条件**

- always 总是运行，无论`Pipeline`运行的完成状态如何
- changed 只有当前`Pipeline`运行的状态与先前完成的`Pipeline`的状态不同时，才能运行
- failure 仅当当前`Pipeline`处于“失败”状态时才运行，通常在`Web UI`中用红色指示表示。
- success 仅当当前`Pipeline`具有“成功”状态时才运行，通常在具有蓝色或绿色指示的`Web UI`中表示。
- unstable 只有当前`Pipeline`具有“不稳定”状态，通常由测试失败，代码违例等引起，才能运行。通常在具有黄色指示的`Web UI`中表示。
- aborted 只有当前`Pipeline`处于“中止”状态时，才会运行，通常是由于`Pipeline`被手动中止。通常在具有灰色指示的`Web UI`中表示。

例如：

```
Jenkinsfile (Declarative Pipeline)pipeline {    agent any    stages {        stage('Example') {            steps {                echo 'Hello World'            }        }    }    post {         always {             echo 'I will always say Hello again!'        }    }}
```

### 3.3 steps

包含一个或多个阶段指令的序列，该`stages`部分是`Pipeline`描述的大部分“工作”的位置。建议`stages`至少包含至少一个阶段指令，用于连续交付过程的每个离散部分，如构建，测试和部署。

例如：

```
Jenkinsfile (Declarative Pipeline)pipeline {    agent any    stages {        stage('Example') {            steps {                 echo 'Hello World'            }        }    }}
```

### 3.4 environment

该`environment`指令指定一系列键值对，这些对值将被定义为所有步骤的环境变量或阶段特定步骤，具体取决于`environment`指令位于`pipeline`中的位置。

该指令支持一种特殊的帮助方法`credentials()`，可以通过其在`Jenkins`环境中的标识符来访问预定义的凭据。对于类型为`Secret Text`的凭据，该`credentials()`方法将确保指定的环境变量包含`Secret Text`内容。对于“标准用户名和密码”类型的凭证，指定的环境变量将被设置为，`username:password`并且将自动定义两个附加的环境变量：`MYVARNAME_USR`和`MYVARNAME_PSW`相应的。

例如：

```
Jenkinsfile (Declarative Pipeline)pipeline {    agent any    environment {         CC = 'clang'    }    stages {        stage('Example') {            environment {                 AN_ACCESS_KEY = credentials('my-prefined-secret-text')             }            steps {                sh 'printenv'            }        }    }}
```

### 3.5 options

该`options`指令允许在`Pipeline`本身内配置`Pipeline`专用选项。`Pipeline`提供了许多这些选项，例如`buildDiscarder`，但它们也可能由插件提供，例如`timestamps`。

**可用选项**

- buildDiscarder 持久化工件和控制台输出，用于最近Pipeline运行的具体数量。例如：`options { buildDiscarder(logRotator(numToKeepStr: '1')) }`
- disableConcurrentBuilds 不允许并行执行`Pipeline`。可用于防止同时访问共享资源等。例如：`options { disableConcurrentBuilds() }`
- overrideIndexTriggers 允许覆盖分支索引触发器的默认处理。如果分支索引触发器在多分支或组织标签中禁用, `options { overrideIndexTriggers(true) }`将只允许它们用于促工作。否则, `options { overrideIndexTriggers(false) }`只会禁用改作业的分支索引触发器。
- skipDefaultCheckout 在`agent`指令中默认跳过来自源代码控制的代码。例如：`options { skipDefaultCheckout() }`
- skipStagesAfterUnstable 一旦构建状态进入了“不稳定”状态，就跳过阶段。例如：`options { skipStagesAfterUnstable() }`
- checkoutToSubdirectory 在工作空间的子目录中自动地执行源代码控制检出。例如: `options { checkoutToSubdirectory('foo') }`
- timeout 设置`Pipeline`运行的超时时间，之后`Jenkins`应该中止`Pipeline`。例如：`options { timeout(time: 1, unit: 'HOURS') }`
- retry 失败后，重试整个`Pipeline`指定的次数。例如：`options { retry(3) }`
- timestamps 预处理由`Pipeline`生成的所有控制台输出运行时间与发射线的时间。例如：`options { timestamps() }`

例如：

```
Jenkinsfile (Declarative Pipeline)pipeline {    agent any    options {        timeout(time: 1, unit: 'HOURS')     }    stages {        stage('Example') {            steps {                echo 'Hello World'            }        }    }}
```

指定一个小时的全局执行超时，之后`Jenkins`将中止`Pipeline`运行。

### 3.6 parameters

该`parameters`指令提供用户在触发`Pipeline`时应提供的参数列表。这些用户指定的参数的值通过该`params`对象可用于`Pipeline`步骤。

**可用参数**

- string 字符串类型的参数，例如：`parameters { string(name: 'DEPLOY_ENV', defaultValue: 'staging', description: '') }`
- text 文本参数，可以包含多行，例如：`parameters { text(name: 'DEPLOY_TEXT', defaultValue: 'One\nTwo\nThree\n', description: '') }`
- booleanParam 布尔参数，例如：`parameters { booleanParam(name: 'DEBUG_BUILD', defaultValue: true, description: '') }`
- choice 选择参数，例如：`parameters { choice(name: 'CHOICES', choices: ['one', 'two', 'three'], description: '') }`
- password 密码参数，例如：`parameters { password(name: 'PASSWORD', defaultValue: 'SECRET', description: 'A secret password') }`

例如：

```
pipeline {    agent any    parameters {        string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')        text(name: 'BIOGRAPHY', defaultValue: '', description: 'Enter some information about the person')        booleanParam(name: 'TOGGLE', defaultValue: true, description: 'Toggle this value')        choice(name: 'CHOICE', choices: ['One', 'Two', 'Three'], description: 'Pick something')        password(name: 'PASSWORD', defaultValue: 'SECRET', description: 'Enter a password')    }    stages {        stage('Example') {            steps {                echo "Hello ${params.PERSON}"                echo "Biography: ${params.BIOGRAPHY}"                echo "Toggle: ${params.TOGGLE}"                echo "Choice: ${params.CHOICE}"                echo "Password: ${params.PASSWORD}"            }        }    }}
```

### 3.7 triggers

该`triggers`指令定义了应重新触发的自动化方式。对于与`GitHub`或`BitBucket`之类的源集成的管道，`triggers`由于基于Webhooks的集成可能已经存在，因此可能没有必要。目前可用的触发器 `cron`，`pollSCM`和`upstream`。

- cron 接受`cron`样式的字符串来定义应重新触发管道的常规间隔，例如：`triggers { cron('H */4 * * 1-5') }`
- pollSCM 接受`cron`样式的字符串以定义`Jenkins`应检查新源更改的定期间隔。如果存在新的更改，则将重新触发管道。例如：`triggers { pollSCM('H */4 * * 1-5') }`
- upstream 接受以逗号分隔的作业字符串和阈值。当字符串中的任何作业以最小阈值结束时，将重新触发管道。例如：`triggers { upstream(upstreamProjects: 'job1,job2', threshold: hudson.model.Result.SUCCESS) }`

例如：

```
// Declarative //pipeline {    agent any    triggers {        cron('H */4 * * 1-5')    }    stages {        stage('Example') {            steps {                echo 'Hello World'            }        }    }}
```

更多`jenkins cron`语法，可参考官方说明

### 3.8 stage

该`stage`指令位于该`stages`节中，并且应包含 steps节，可选`agent`节或其他特定于阶段的指令。实际上，管道完成的所有实际工作都将包含在一个或多个`stage`指令中。

例如：

```
// Declarative //pipeline {    agent any    stages {        stage('Example') {            steps {                echo 'Hello World'            }        }    }}
```

### 3.9 tools

定义自动安装并放在上的工具的部分`PATH`。如果`agent none`指定，则将其忽略。

例如：

```
pipeline {    agent any    tools {        maven 'apache-maven-3.0.1'     }    stages {        stage('Example') {            steps {                sh 'mvn --version'            }        }    }}
```

### 3.10 input

`input`指令`stage`允许使用`inputstep`提示输入。在`stage`将暂停任何后`options`已被应用，并在进入前`agent`块为`stage`或评估`when`的条件`stage`。如果`input`批准，`stage`则将继续。作为`input`提交的一部分提供的任何参数将在其余的环境中可用`stage`。

**可选项**

- message 必需的，这将在用户提交时显示给用户`input`
- id 可选标识符`input`，默认为`stage`名称
- ok`input`表单上“确定”按钮的可选文本
- submitter 可选的逗号分隔列表，这些列表允许用户提交此用户或外部组名`input`。默认为允许任何用户。
- submitterParameter 环境变量的可选名称，用该`submitter`名称设置（如果存在）
- parameters 提示提交者提供的可选参数列表。请参阅parameters以获取更多信息

例如：

```
pipeline {    agent any    stages {        stage('Example') {            input {                message "Should we continue?"                ok "Yes, we should."                submitter "alice,bob"                parameters {                    string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')                }            }            steps {                echo "Hello, ${PERSON}, nice to meet you."            }        }    }}
```

### 3.11 when

该`when`指令允许`Pipeline`根据给定的条件确定是否执行该阶段。该`when`指令必须至少包含一个条件。如果`when`指令包含多个条件，则所有子条件必须为舞台执行返回`true`。这与子条件嵌套在一个`allOf`条件中相同。更复杂的条件结构可使用嵌套条件：`not`，`allOf`或`anyOf`。嵌套条件可以嵌套到任意深度。

**内置条件**

- branch 当正在构建的分支与给出的分支模式匹配时执行阶段，例如：`when { branch 'master' }`。仅适用于多分支`Pipeline`。

```
Jenkinsfile (Declarative Pipeline)pipeline {    agent any    stages {        stage('Example Build') {            steps {                echo 'Hello World'            }        }        stage('Example Deploy') {            when {                branch 'production'            }            steps {                echo 'Deploying'            }        }    }}
```

- environment 当指定的环境变量设置为给定值时执行阶段，例如：`when { environment name: 'DEPLOY_TO', value: 'production' }`

```
Jenkinsfile (Declarative Pipeline)pipeline {    agent any    stages {        stage('Example Build') {            steps {                echo 'Hello World'            }        }        stage('Example Deploy') {            when {                branch 'production'                environment name: 'DEPLOY_TO', value: 'production'            }            steps {                echo 'Deploying'            }        }    }}
```

- expression 当指定的`Groovy`表达式求值为`true`时执行阶段，例如：`when { expression { return params.DEBUG_BUILD } }`

```
pipeline {    agent any    stages {        stage('Example Build') {            steps {                echo 'Hello World'            }        }        stage('Example Deploy') {            when {                expression { BRANCH_NAME ==~ /(production|staging)/ }                anyOf {                    environment name: 'DEPLOY_TO', value: 'production'                    environment name: 'DEPLOY_TO', value: 'staging'                }            }            steps {                echo 'Deploying'            }        }    }}
```

- not 当嵌套条件为`false`时执行阶段。必须包含一个条件。例如：`when { not { branch 'master' } }`
- allOf 当所有嵌套条件都为真时，执行。必须至少包含一个条件。例如：`when { allOf { branch 'master'; environment name: 'DEPLOY_TO', value: 'production' } }`

```
pipeline {    agent any    stages {        stage('Example Build') {            steps {                echo 'Hello World'            }        }        stage('Example Deploy') {            when {                allOf {                    branch 'production'                    environment name: 'DEPLOY_TO', value: 'production'                }            }            steps {                echo 'Deploying'            }        }    }}
```

- anyOf 当至少一个嵌套条件为真时执行。必须至少包含一个条件。例如：`when { anyOf { branch 'master'; branch 'staging' } }`

```
pipeline {    agent any    stages {        stage('Example Build') {            steps {                echo 'Hello World'            }        }        stage('Example Deploy') {            when {                expression { BRANCH_NAME ==~ /(production|staging)/ }                anyOf {                    environment name: 'DEPLOY_TO', value: 'production'                    environment name: 'DEPLOY_TO', value: 'staging'                }            }            steps {                echo 'Deploying'            }        }    }}
```

### 3.12 parallel

声明性管道中的阶段可能有一个`parallel`部分，其中包含要并行运行的嵌套阶段的列表。需要注意的是一个阶段都必须有且只有一个`steps`，`stages`，`parallel`，或`matrix`。这是不可能的嵌套`parallel`或`matrix`块内`stage`，如果该指令`stage`指令嵌套在一个`parallel`或`matrix`阻塞本身。然而，`stage`一个内指令`parallel`或`matrix`块可以使用的所有其它的功能`stage`，包括`agent`，`tools`，`when`等。

```
pipeline {    agent any    stages {        stage('Non-Parallel Stage') {            steps {                echo 'This stage will be executed first.'            }        }        stage('Parallel Stage') {            when {                branch 'master'            }            failFast true            parallel {                stage('Branch A') {                    agent {                        label "for-branch-a"                    }                    steps {                        echo "On Branch A"                    }                }                stage('Branch B') {                    agent {                        label "for-branch-b"                    }                    steps {                        echo "On Branch B"                    }                }                stage('Branch C') {                    agent {                        label "for-branch-c"                    }                    stages {                        stage('Nested 1') {                            steps {                                echo "In stage Nested 1 within Branch C"                            }                        }                        stage('Nested 2') {                            steps {                                echo "In stage Nested 2 within Branch C"                            }                        }                    }                }            }        }    }}
```

此外，你可以`parallel`阶段时，它们中的任何一个发生故障，所有被中止，加入`failFast true`到`stage`含有`parallel`。添加的另一个选项`failfast`是在管道定义中添加一个选项：`parallelsAlwaysFailFast()`

```
pipeline {    agent any    options {        parallelsAlwaysFailFast()    }    stages {        stage('Non-Parallel Stage') {            steps {                echo 'This stage will be executed first.'            }        }        stage('Parallel Stage') {            when {                branch 'master'            }            parallel {                stage('Branch A') {                    agent {                        label "for-branch-a"                    }                    steps {                        echo "On Branch A"                    }                }                stage('Branch B') {                    agent {                        label "for-branch-b"                    }                    steps {                        echo "On Branch B"                    }                }                stage('Branch C') {                    agent {                        label "for-branch-c"                    }                    stages {                        stage('Nested 1') {                            steps {                                echo "In stage Nested 1 within Branch C"                            }                        }                        stage('Nested 2') {                            steps {                                echo "In stage Nested 2 within Branch C"                            }                        }                    }                }            }        }    }}
```

## 4、其他

### 4.1 在声明式pipeline中使用脚本

声明式`pipeline`是不能直接在`steps`块中写`Groovy`代码。`Jenkins pipeline`专门提供了一个`script`步骤，你能在`script`步骤中像写代码一样写`pipeline`逻辑。

```
pipeline {    agent any    stages {        stage('Build') {            steps {                script {                    result = sh (script: "git log -1|grep 'Release'", returnStatus: true)                     echo "result: ${result}"                }            }        }    }}
```

在`script`块中的其实就是`Groovy`代码。大多数时候，我们是不需要使用`script`步骤的。如果在`script`步骤中写了大量的逻辑，则说明你应该把这些逻辑拆分到不同的阶段，或者放到共享库中。共享库是一种扩展`Jenkins pipeline`的技术。

### 4.2 pipeline内置基础步骤

#### 4.2.1 文件目录相关步骤

- deleteDir 删除当前目录，它是一个无参步骤，删除的是当前工作目录。通常它与`dir`步骤一起使用，用于删除指定目录下的内容。
- dir 切换到目录。默认`pipeline`工作在工作空间目录下，`dir`步骤可以让我们切换到其它目录。例如：dir("/var/logs") { deleteDir() }
- fileExists 判断文件是否存在。`fileExists('/tmp/a.jar')`判断`/tmp/a.jar`文件是否存在。如果参数是相对路径，则判断在相对当前工作目录下，该文件是否存在。结果返回布尔类型。
- isUnix 判断是否为类`Unix`系统。如果当前`pipeline`运行在一个类`Unix`系统上，则返回`true`。
- pwd 确认当前目录。`pwd`与`Linux`的`pwd`命令一样，返回当前所在目录。它有一个布尔类型的可选参数：`tmp`，如果参数值为`true`，则返回与当前工作空间关联的临时目录。
- writeFile 将内容写入指定文件中。

`writeFile`支持的参数有：file：文件路径，可以是绝对路径，也可以是相对路径。text：要写入的文件内容。encoding（可选）：目标文件的编码。如果留空，则使用操作系统默认的编码。如果写的是`Base64`的数据，则可以使用`Base64`编码。

- readFile：读取指定文件的内容，以文本返回。

`readFile`支持的参数有：file：路径，可以是绝对路径，也可以是相对路径。encoding（可选）：读取文件时使用的编码。

```
script {    // "amVua2lucyBib29r" 是"jenkins book"进行Base64编码后的值    writeFile(file: "base64File", text: "amVua2lucyBib29r", encoding: "Base64")    def content = readFile(file: "base64File", encoding: "UTF-8")    echo "${content}"    // 打印结果: jenkins book}
```

#### 4.2.2 制品相关步骤

- stash 保存临时文件。`stash`步骤可以将一些文件保存起来，以便被同一次构建的其他步骤或阶段使用。如果整个`pipeline`的所有阶段在同一台机器上执行，则`stash`步骤是多余的。所以，通常需要`stash`的文件都是要跨`Jenkins node`使用的。

`stash`步骤会将文件存储在`tar`文件中，对于大文件的`stash`操作将会消耗`Jenkins master`的计算资源。`Jenkins`官方文档推荐，当文件大小为`5∼100MB`时，应该考虑使用其他替代方案。

`stash`步骤的参数列表如下：

- name：字符串类型，保存文件的集合的唯一标识。
- allowEmpty：布尔类型，允许`stash`内容为空。
- excludes：字符串类型，将哪些文件排除。如果排除多个文件，则使用逗号分隔。留空代表不排除任何文件。
- includes：字符串类型，`stash`哪些文件，留空代表当前文件夹下的所有文件。
- useDefaultExcludes：布尔类型，如果为`true`，则代表使用`Ant`风格路径默认排除文件列表。除了`name`参数，其他参数都是可选的。`excludes`和`includes`使用的是`Ant`风格路径表达式。
- unstash 取出之前`stash`的文件。`unstash`步骤只有一个`name`参数，即`stash`时的唯一标识。通常`stash`与`unstash`步骤同时使用。以下是完整示例。

```
pipeline {    agent none    stages {        stage('stash') {            agent { label "master" }            steps {                script {                    writeFile file: "a.txt", text: "$BUILD_NUMBER"                    stash(name: "abc", include: "a.txt")                }            }        }        stage("unstash") {            agent { label "node2" }            steps {                script {                    unstash("abc")                    def content = readFile("a.txt")                    echo "${content}"                }            }        }    }}
```

`stash`步骤在`master`节点上执行，而`unstash`步骤在`node2`节点上执行

#### 4.2.3 命令相关步骤

与命令相关的步骤其实是`Pipeline`：`Nodes and Processes`插件提供的步骤。由于它是`Pipeline`插件的一个组件，所以基本不需要单独安装。

**sh**执行`shell`命令。`sh`步骤支持的参数有：

- `script`：将要执行的shell脚本，通常在类UNIX系统上可以是多行脚本。
- `encoding`：脚本执行后输出日志的编码，默认值为脚本运行所在系统的编码。
- `returnStatus`：布尔类型，默认脚本返回的是状态码，如果是一个非零的状态码，则会引发pipeline执行失败。如果`returnStatus`参数为`true`，则不论状态码是什么，pipeline的执行都不会受影响。
- `returnStdout`：布尔类型，如果为`true`，则任务的标准输出将作为步骤的返回值，而不是打印到构建日志中（如果有错误，则依然会打印到日志中）。除了`script`参数，其他参数都是可选的。

`returnStatus`与`returnStdout`参数一般不会同时使用，因为返回值只能有一个。如果同时使用，则只有`returnStatus`参数生效。

**bat、powershell**`bat`步骤执行的是`Windows`的批处理命令。`powershell`步骤执行的是`PowerShell`脚本，支持3+版本。这两个步骤支持的参数与`sh`步骤的一样。

#### 4.2.4 其他步骤

- error 主动报错，中止当前`pipeline`。`error`步骤的执行类似于抛出一个异常。它只有一个必需参数：`message`。通常省略参数：`error（"there's an error"）`。

- tool 使用预定义的工具。如果在`Global Tool Configuration`（全局工具配置）中配置了工具，那么可以通过`tool`步骤得到工具路径。`tool`步骤支持的参数有：

- - name：工具名称。
  - type（可选）：工具类型，指该工具安装类的全路径类名。每个插件的`type`值都不一样，而且绝大多数插件的文档根本不写`type`值。除了到该插件的源码中查找，还有一种方法可以让我们快速找到`type`值，就是前往`Jenkins pipeline`代码片段生成器中生成该`tool`步骤的代码即可。

- timeout 代码块超时时间。为`timeout`步骤闭包内运行的代码设置超时时间限制。如果超时，将抛出一个`org.jenkinsci.plugins.workflow.steps.FlowInterruptedException`异常。`timeout`步骤支持如下参数：

- - time：整型，超时时间。
  - unit（可选）：时间单位，支持的值有`NANOSECONDS`、`MICROSECONDS`、`MILLISECONDS`、`SECONDS`、`MINUTES`（默认）、`HOURS`、`DAYS`。
  - activity（可选）：布尔类型，如果值为`true`，则只有当日志没有活动后，才真正算作超时。
  - waitUntil 等待条件满足。不断重复`waitUntil`块内的代码，直到条件为`true`。`waitUntil`不负责处理块内代码的异常，遇到异常时直接向外抛出。`waitUntil`步骤最好与`timeout`步骤共同使用，避免死循环。示例如下：

```
timeout(50) {    waitUntil {        script {            def r = sh script: 'curl http://example', returnStatus: true            retturn (r == 0)        }    }}
```

- retry 重复执行块 执行`N`次闭包内的脚本。如果其中某次执行抛出异常，则只中止本次执行，并不会中止整个`retry`的执行。同时，在执行`retry`的过程中，用户是无法中止`pipeline`的。

```
steps {    retry(20) {        script {            sh script: 'curl http://example', returnStatus: true        }    }}
```

- sleep 让`pipeline`休眠一段时间。`sleep`步骤可用于简单地暂停`pipeline`，其支持的参数有：
- time：整型，休眠时间。
- unit（可选）：时间单位，支持的值有`NANOSECONDS`、`MICROSECONDS`、`MILLISECONDS`、`SECONDS`（默认）、`MINUTES`、`HOURS`、`DAYS`。

