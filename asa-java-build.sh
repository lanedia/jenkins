#!/bin/bash
cd ${MODULE_NAME}
GITREV=`git rev-list HEAD|wc -l`
REPOSITORY=asa/${MODULE_NAME}
TAG=${REPOSITORY}:${GITREV}

testfile=Dockerfile
test -s ${testfile} ||{ echo "${testfile} not found. Exiting."; exit 1; }

testfile=target/message-router-3.1.0-standalone.jar
test -s ${testfile} ||{ echo "${testfile} not found. Exiting."; exit 1; }

#sudo docker build -t ${MODULE_NAME} .
sudo docker build --no-cache -t ${TAG} -f ./Dockerfile .


