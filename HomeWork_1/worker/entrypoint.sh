#!/bin/bash

echo "Start SSH service"
sudo service ssh start

echo "Start Hadoop daemons"
hdfs --daemon start datanode

echo "Start yarn's nodemanager"
yarn --daemon start nodemanager

tail -f /dev/null
