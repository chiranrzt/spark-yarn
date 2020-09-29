FROM ubuntu:bionic
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64/jre
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR /opt/hadoop/etc/hadoop
ENV SPARK_HOME /opt/spark
ENV PATH="${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${PATH}"
ENV HADOOP_VERSION 3.3.0
ENV PYSPARK_PYTHON=python3
ENV HDFS_NAMENODE_USER="root"
ENV HDFS_DATANODE_USER="root"
ENV HDFS_SECONDARYNAMENODE_USER="root"
ENV YARN_RESOURCEMANAGER_USER="root"
ENV YARN_NODEMANAGER_USER="root"
ENV HDFS_JOURNALNODE_USER="root"
ENV YARN_PROXYSERVER_USER="root"
RUN apt-get update && \
    apt-get install -y wget nano openjdk-8-jdk ssh openssh-server
RUN apt update && apt install -y python3 python3-pip python3-dev build-essential libssl-dev libffi-dev libpq-dev krb5-user

COPY /confs/requirements.req /
RUN pip3 install -r requirements.req
RUN pip3 install dask[bag] --upgrade
RUN pip3 install --upgrade toree
RUN python3 -m bash_kernel.install

RUN wget -P /tmp/ http://apachemirror.wuchna.com/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz
RUN tar xvf /tmp/hadoop-3.3.0.tar.gz -C /tmp && \
	mv /tmp/hadoop-3.3.0 /opt/hadoop

RUN wget -P /tmp/ http://apachemirror.wuchna.com/spark/spark-3.0.1/spark-3.0.1-bin-hadoop3.2.tgz
RUN tar xvf /tmp/spark-3.0.1-bin-hadoop3.2.tgz -C /tmp && \
    mv /tmp/spark-3.0.1-bin-hadoop3.2 ${SPARK_HOME}

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
	chmod 600 ~/.ssh/authorized_keys
COPY /confs/config /root/.ssh
RUN chmod 600 /root/.ssh/config

COPY /confs/*.xml /opt/hadoop/etc/hadoop/
COPY /confs/slaves /opt/hadoop/etc/hadoop/
COPY /confs/workers /opt/hadoop/etc/hadoop/
COPY /confs/slaves /opt/spark/conf/
COPY /confs/workers /opt/spark/conf/
COPY /script_files/bootstrap.sh /
COPY /confs/spark-defaults.conf ${SPARK_HOME}/conf

RUN echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/environment

EXPOSE 9000
EXPOSE 7077
EXPOSE 4040
EXPOSE 8020
EXPOSE 22


ENTRYPOINT ["/bin/bash", "bootstrap.sh"]
