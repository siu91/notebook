FROM liaocs559/centos:7.1

ADD server-jre-8u281-linux-x64.tar  /usr/local/
ENV LANG en_US.UTF-8
# 指定容器内jdk所在目录
ENV JAVA_VERSION 1.8.0
ENV JAVA_HOME /usr/local/jdk1.8.0_281
ENV CLASSPATH $JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
ENV PATH $PATH:$JAVA_HOME/bin:$JAVA_HOME/sbin