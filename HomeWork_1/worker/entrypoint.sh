#!/bin/bash

echo "Start SSH service"
sudo service ssh start

echo "Start Hadoop daemons"
hdfs --daemon start datanode

tail -f /dev/null
