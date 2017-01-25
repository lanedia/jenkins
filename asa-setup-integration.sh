
#!/bin/bash
GITREV="latest"
REPOSITORY=asa/${MODULE_NAME}
REGISTRY=shdocker-reg:5000


# Ensure the docker containers are stopped before removing them
# Remove the docker containers in order to launch new images
#echo "skipping shell script, & using docker plugin"
#exit 0
set -x
echo "stop & remove zookeeper"
sudo docker stop zookeeper || echo "zookeeper container not running"
sudo docker rm zookeeper || echo "No zookeeper container to remove"
echo "stop & remove kafka"
sudo docker stop kafka | echo "kafka container not running"
sudo docker rm kafka || echo "No kafka container to remove"
echo "stop & remove redis"
sudo docker stop redis  || echo "redis container not running"
sudo docker rm redis || echo "No redis container to remove"
echo "LIBRARY_PROJECT=${LIBRARY_PROJECT}"

#echo "stop & remove ${MODULE_NAME}"
#sudo docker stop ${MODULE_NAME} || echo "${MODULE_NAME} container not running"
#sudo docker rm ${MODULE_NAME} || echo "No ${MODULE_NAME} container to remove"
#echo "stop & remove ${MODULE_NAME}-test"
#sudo docker stop ${MODULE_NAME}-test || echo "${MODULE_NAME}-test container not running"
#sudo docker rm ${MODULE_NAME}-test || echo "No ${MODULE_NAME}-test container to remove"


# Launch the containers required to run functional tests
# zookeeper
# kafka
# redis
# ${MODULE_NAME}
# ${MODULE_NAME}-test
#
echo "Launch zookeeper"
sudo docker run -d     --net=host     --name=zookeeper     -e ZOOKEEPER_CLIENT_PORT=2181     confluentinc/cp-zookeeper:3.1.0
echo "Launch kafka"
sudo docker run -d     --net=host     --name=kafka     -e KAFKA_ZOOKEEPER_CONNECT=localhost:2181     -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092     confluentinc/cp-kafka:3.1.0

echo "Launch redis"
sudo docker run -d --net=host --name redis -p 6379:6379 redis

echo "Launch ASA MS's"

for myMicroService in ${microServiceList}
do
	echo "myString = ${myMicroService}"
	REPOSITORY=asa/${myMicroService}
	sudo docker pull ${REGISTRY}/${REPOSITORY}:latest

	sudo docker stop ${myMicroService} && sudo docker rm ${myMicroService} || echo "No ${myMicroService} container to remove"
	sudo docker run -d --net=host --name ${myMicroService} ${REGISTRY}/${REPOSITORY}:latest
done

