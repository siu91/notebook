
FROM liaocs559/jdk8:1.8.0_281-centos7.1

ARG VERSION=4.7
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

RUN yum -y update \
    && yum -y install git \
    && yum -y install sshpass \
    && yum clean all

RUN groupadd -g ${gid} ${group} \
    && useradd -d /home/${user} -u ${uid} -g ${group} ${user}

LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent

RUN curl --create-dirs -fsSLo /usr/share/jenkins/agent.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/agent.jar \
  && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar
USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}
