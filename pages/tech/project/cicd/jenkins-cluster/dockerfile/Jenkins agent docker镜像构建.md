# Jenkins agent docker镜像构建

### 构建centos(基础镜像)

```shell
#通过dockerfile 构建镜像
docker build -t="centos:7.1" .
#给镜像打标签《源镜像标签》《目标镜像标签》
docker tag centos:7.1 liaocs559/centos:7.1
#推送镜像到仓库liaocs559（用户名）
docker push liaocs559/centos:7.1
```

### 构建jre8镜像

```shell
#通过dockerfile 构建镜像
docker build -t="jdk8:1.8.0_281-centos7.1" .
#给镜像打标签《源镜像标签》《目标镜像标签》
docker tag jdk8:1.8.0_281-centos7.1 liaocs559/jdk8:1.8.0_281-centos7.1
#推送镜像到仓库liaocs559（用户名）
docker push liaocs559/jdk8:1.8.0_281-centos7.1
```

### 构建jenkins/agent 镜像（jenkins agent基础镜像）

```shell
#通过dockerfile 构建镜像
docker build -t="jenkins/agent:4.7-1-jdk8-centos7.1" .
#给镜像打标签《源镜像标签》《目标镜像标签》
docker tag jenkins/agent:4.7-1-jdk8-centos7.1 liaocs559/jenkins-agent:4.7-1-jdk8-centos7.1
#推送镜像到仓库liaocs559（用户名）
docker push liaocs559/jenkins-agent:4.7-1-jdk8-centos7.1
```

### 构建maven-jenkins/agent 镜像

```shell
#通过dockerfile 构建镜像
docker build -t="jenkins/agent:4.7-1-jdk8-centos7-maven.1" .
#给镜像打标签《源镜像标签》《目标镜像标签》
docker tag jenkins/agent:4.7-1-jdk8-centos7-maven.1 liaocs559/jenkins-agent:4.7-1-jdk8-centos7-maven.1
#推送镜像到仓库liaocs559（用户名）
docker push liaocs559/jenkins-agent:4.7-1-jdk8-centos7-maven.1
```

### 构建nodejs-jenkins/agent 镜像

```shell
#通过dockerfile 构建镜像
docker build -t="jenkins/agent:4.7-1-jdk8-centos7-nodejs.1" .
#给镜像打标签《源镜像标签》《目标镜像标签》
docker tag jenkins/agent:4.7-1-jdk8-centos7-nodejs.1 liaocs559/jenkins-agent:4.7-1-jdk8-centos7-nodejs.1
#推送镜像到仓库liaocs559（用户名）
docker push liaocs559/jenkins-agent:4.7-1-jdk8-centos7-nodejs.1
```

