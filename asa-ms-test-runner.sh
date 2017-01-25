#!/bin/bash
#GITREV=$(echo $(git rev-list HEAD | wc -l)-$(git rev-parse --short HEAD))
#GITREV=1
#GITREV=`git rev-list HEAD|wc -l`
REPOSITORY=asa/${MODULE_NAME}
#TAG=${REPOSITORY}:${GITREV}
REGISTRY=shdocker-reg:5000
#REGISTRY=ci-docker-registry.tecnotree.com

#sudo docker push ${REGISTRY}/${TAG}
sudo docker pull ${REGISTRY}/${REPOSITORY}:latest

# Ensure the docker containers are stopped before removing them
# Remove the docker containers in order to launch new images
#echo "skipping shell script, & using docker plugin"
#exit 0
set +x
echo "stop & remove zookeeper"
sudo docker stop zookeeper || echo "zookeeper container not running"
sudo docker rm zookeeper || echo "No zookeeper container to remove"
echo "stop & remove kafka"
sudo docker stop kafka|| echo "kafka container not running"
sudo docker rm kafka || echo "No kafka container to remove"
echo "stop & remove redis"
sudo docker stop redis && sudo docker rm redis
echo "LIBRARY_PROJECT=${LIBRARY_PROJECT}"

echo "stop & remove ${MODULE_NAME}"
sudo docker stop ${MODULE_NAME} || echo "${MODULE_NAME} container not running"
sudo docker rm ${MODULE_NAME} || echo "No ${MODULE_NAME} container to remove"
echo "stop & remove ${MODULE_NAME}-test"
sudo docker stop ${MODULE_NAME}-test || echo "${MODULE_NAME}-test container not running"
sudo docker rm ${MODULE_NAME}-test || echo "No ${MODULE_NAME}-test container to remove"


# Launch the containers required to run functional tests
# zookeeper
# kafka
# redis
# ${MODULE_NAME}
# ${MODULE_NAME}-test
#
echo "Launch zookeeper"
sudo docker run -d     --net=host     --name=zookeeper     -e ZOOKEEPER_CLIENT_PORT=2181     confluentinc/cp-zookeeper:3.1.0
sudo docker run -d     --net=host     --name=kafka     -e KAFKA_ZOOKEEPER_CONNECT=localhost:2181     -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092     confluentinc/cp-kafka:3.1.0

sudo docker run -d --net=host --name redis -p 6379:6379 redis:alpine


sudo docker run -d --net=host --name ${MODULE_NAME} ${REGISTRY}/${REPOSITORY}:latest && sleep 10;sudo docker run -d --net=host --name ${MODULE_NAME}-test ${REGISTRY}/${REPOSITORY}:latest  test
#sudo docker run -d --net=host --name ${MODULE_NAME} ${MODULE_NAME} && sleep 10;sudo docker run -d --net=host --name ${MODULE_NAME}-test ${MODULE_NAME}  test
sleep 40
#sudo docker ps -l |grep Exit && sudo docker logs ${MODULE_NAME}-test || echo "Still running ${MODULE_NAME}-test"
echo "Still running ${MODULE_NAME}-test"
sudo docker logs ${MODULE_NAME}-test

sudo docker logs ${MODULE_NAME}-test|grep -i failing && echo "Tests failing";exit 1 || echo "All tests passing"; exit 0

