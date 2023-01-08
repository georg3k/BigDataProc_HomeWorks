FROM ubuntu:14.04

LABEL maintainer="Georgiy Kryuchkov kryuchkovgm@bmstu.ru, Natalia Ovchinnikova ovchinnikovanp@student.bmstu.ru"


# ======================
#
# Install packages 
#
# ======================

RUN apt-get update && apt-get install -y openssh-server software-properties-common nano && \
    add-apt-repository ppa:openjdk-r/ppa && \
    apt update && apt -y install openjdk-8-jdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# ======================
#
# Create user
#
# ======================

# User home directory
ENV HOME /home/bigdata

# Create user
RUN useradd -m -p '$(openssl passwd -l bigdata)' bigdata

# Set current dir
WORKDIR /home/bigdata

# Add sudo permission for hadoop user to start ssh service
RUN usermod -aG sudo bigdata

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/
RUN chmod 755 /usr/local/bin/entrypoint.sh

# ======================
#
# Install Hadoop
#
# ======================

# Change root to the bigdata user
USER bigdata

# Install Hadoop
RUN mkdir hadoop && \
    wget -P /home/bigdata/sources https://archive.apache.org/dist/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz && \
    tar xf sources/hadoop-3.1.2.tar.gz --directory hadoop --strip-components 1 && \
    rm -rf sources/hadoop-3.1.2.tar.gz

# Set Hadoop environment variables
RUN export HDFS_NAMENODE_USER=bigdata && \
    export HDFS_DATANODE_USER=bigdata && \
    export HDFS_SECONDARYNAMENODE_USER=bigdata && \
    export YARN_NODEMANAGER_USER=bigdata && \
    export YARN_RESOURCEMANAGER_USER=bigdata && \
    export HADOOP_HOME=$HOME/hadoop && \
    export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop && \
    export PATH=$HADOOP_HOME/bin:$HADOOP_HOME:$PATH

# Copy hadoop configuration files
COPY --chown=bigdata:bigdata ["config/hdfs", "config/yarn", "config/mapreduce", "$HADOOP_CONF_DIR/"]

ENTRYPOINT ["sh", "/usr/local/bin/entrypoint.sh"]