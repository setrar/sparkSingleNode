#!/bin/bash

# Let's make room for this
BIGD_DIST=$HOME/bin/local/bigdata

# Is it cleaned up?
rm -rf ${BIGD_DIST}
mkdir -p ${BIGD_DIST}

# Installing Hadoop and Yarn
HADOOP_VERSION=2.5.2
wget http://mirror.reverse.net/pub/apache/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz -O ${BIGD_DIST}/hadoop-${HADOOP_VERSION}.tar.gz
tar zxvf ${BIGD_DIST}/hadoop-${HADOOP_VERSION}.tar.gz -C ${BIGD_DIST}
ln -s ${BIGD_DIST}/hadoop-${HADOOP_VERSION} ${BIGD_DIST}/hadoop
rm ${BIGD_DIST}/hadoop-${HADOOP_VERSION}.tar.gz

SPARK_VERSION=1.1.1
HADOOP_SPARK_VERSION=2.4
wget http://www.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_SPARK_VERSION}.tgz  -O ${BIGD_DIST}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_SPARK_VERSION}.tgz
tar zxvf ${BIGD_DIST}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_SPARK_VERSION}.tgz -C ${BIGD_DIST}
ln -s ${BIGD_DIST}//spark-${SPARK_VERSION}-bin-hadoop${HADOOP_SPARK_VERSION} ${BIGD_DIST}/spark
rm ${BIGD_DIST}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_SPARK_VERSION}.tgz

#
#
# The below configuration is to allow Hadoop to run on a single node
#
#

# Setup passphraseless ssh
# If you cannot ssh to $hostname without a passphrase, execute the following commands:
rm ~/.ssh/id_dsa
rm ~/.ssh/id_dsa.pub
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub > ~/.ssh/authorized_keys 

# enable ssh localhost access for Hadoop Services
rm ~/.ssh/config
echo "Host localhost"                    >  ~/.ssh/config
echo "HostName ${HOSTNAME}"              >> ~/.ssh/config
echo "Port 22"                           >> ~/.ssh/config
echo "User fvisbadm"                     >> ~/.ssh/config

# The below example were taken from Hadoop websites
# For some reasons , the hadoop-site.xml is split in multiple files
mkdir -p ${BIGD_DIST}/hadoop/etc/hadoop

# conf/core-site.xml:
cp ${BIGD_DIST}/hadoop/share/hadoop/common/templates/core-site.xml ${BIGD_DIST}/hadoop/etc/hadoop/core-site.xml.orig
sed -e '/<configuration>/ a \\t <property>\n\t\t<name>fs.defaultFS<\/name>\n\t\t<value>hdfs:\/\/'${HOSTNAME}':9000<\/value>\n\t<\/property>' < ${BIGD_DIST}/hadoop/etc/hadoop/core-site.xml.orig > ${BIGD_DIST}/hadoop/etc/hadoop/core-site.xml

#conf/hdfs-site.xml:
cp ${BIGD_DIST}/hadoop/share/hadoop/hdfs/templates/hdfs-site.xml ${BIGD_DIST}/hadoop/etc/hadoop/hdfs-site.xml.orig
sed -e '/<configuration>/ a \\t <property>\n\t\t<name>dfs.replication<\/name>\n\t\t<value>1<\/value>\n\t<\/property>' < ${BIGD_DIST}/hadoop/etc/hadoop/hdfs-site.xml.orig > ${BIGD_DIST}/hadoop/etc/hadoop/hdfs-site.xml

# conf/mapred-site.xml:
cp ${BIGD_DIST}/hadoop/share/hadoop/common/templates/core-site.xml ${BIGD_DIST}/hadoop/etc/hadoop/mapred-site.xml.orig
sed -e '/<configuration>/ a \\t <property>\n\t\t<name>mapreduce.framework.name<\/name>\n\t\t<value>yarn<\/value>\n\t<\/property>' < ${BIGD_DIST}/hadoop/etc/hadoop/mapred-site.xml.orig > ${BIGD_DIST}/hadoop/etc/hadoop/mapred-site.xml

# conf/yarn-site.xml:
cp ${BIGD_DIST}/hadoop/share/hadoop/common/templates/core-site.xml ${BIGD_DIST}/hadoop/etc/hadoop/yarn-site.xml.orig
sed -e '/<configuration>/ a \\t <property>\n\t\t<name>yarn.nodemanager.aux-services<\/name>\n\t\t<value>mapreduce_shuffle<\/value>\n\t<\/property>' < ${BIGD_DIST}/hadoop/etc/hadoop/yarn-site.xml.orig > ${BIGD_DIST}/hadoop/etc/hadoop/yarn-site.xml

