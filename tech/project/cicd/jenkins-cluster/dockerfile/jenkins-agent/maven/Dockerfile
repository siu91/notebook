
FROM liaocs559/jenkins-agent:4.7-1-jdk8-centos7.1


ADD apache-maven-3.6.1-bin.tar  /usr/local/

ENV MAVEN_HOME /usr/local/apache-maven-3.6.1
ENV PATH $PATH:$MAVEN_HOME/bin
CMD <mvn -v>