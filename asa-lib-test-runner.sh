#!/bin/bash
# Ensure the docker containers are stopped before removing them
# Remove the docker containers in order to launch new images
#echo "skipping shell script, & using docker plugin"
#exit 0
set -x
echo "stop & remove zookeeper"
sudo docker stop zookeeper || echo "zookeeper container not running"
sudo docker rm zookeeper || echo "No zookeeper container to remove"
echo "stop & remove kafka"
sudo docker stop kafka|| echo "kafka container not running"
sudo docker rm kafka || echo "No kafka container to remove"
echo "stop & remove redis"
sudo docker stop redis && sudo docker rm redis
echo "LIBRARY_PROJECT=${LIBRARY_PROJECT}"

# Launch the containers required to run functional tests
# zookeeper
# kafka
# redis

echo "Launch zookeeper"
sudo docker run -d     --net=host     --name=zookeeper     -e ZOOKEEPER_CLIENT_PORT=2181     confluentinc/cp-zookeeper:3.1.0
sudo docker run -d     --net=host     --name=kafka     -e KAFKA_ZOOKEEPER_CONNECT=localhost:2181     -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092     confluentinc/cp-kafka:3.1.0

sudo docker run -d --net=host --name redis -p 6379:6379 redis:alpine

echo "This is a library project. Run the library tests outside of docker"
echo "Unpacking ${MODULE_NAME}-node_modules.tar.gz artifact..."
cd $MODULE_NAME
ls -al
#tar xzf ../${MODULE_NAME}-node_modules.tar.gz
pwd
ls -al
NPM=$(which npm 2>/dev/null)
test -n "${NPM}" -a -x "${NPM}" || { echo "${NPM:-npm} not found or not executable. Exiting."; exit 1; }
npm cache clean
npm install
./node_modules/mocha/bin/mocha

