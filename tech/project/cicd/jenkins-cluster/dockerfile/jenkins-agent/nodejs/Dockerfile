
FROM liaocs559/jenkins-agent:4.7-1-jdk8-centos7-maven.1

ARG root_user=root
ARG jenkins_user=jenkins

ADD node-v12.16.1-linux-x64.tar.gz  /usr/local/

USER ${root_user}

RUN  ln -s /usr/local/node-v12.16.1-linux-x64/bin/npm  /usr/local/bin/ \
    &&  ln -s /usr/local/node-v12.16.1-linux-x64/bin/node /usr/local/bin/ \
    && npm i npm -g

USER ${jenkins_user}

CMD <"npm -v","node -v">