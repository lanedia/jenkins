#!/bin/bash
set -x

echo "Executing docker publish ${MODULE_NAME}"

cd ${MODULE_NAME}
NPM=$(which npm 2>/dev/null)
test -n "${NPM}" -a -x "${NPM}" || { echo "${NPM:-npm} not found or not executable. Exiting."; exit 1; }

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
set -ue


#GITREV=$(echo $(git rev-list HEAD | wc -l)-$(git rev-parse --short HEAD))
#GITREV=1
GITREV=`git rev-list HEAD|wc -l`
REPOSITORY=asa/${MODULE_NAME}
TAG=${REPOSITORY}:${GITREV}
REGISTRY=shdocker-reg:5000
#REGISTRY=ci-docker-registry.tecnotree.com



#create login credentials to p45-docker-registry-01:
#---------------------------------------------------
#docker login p45-docker-registry-01.lab.tecnotree.com
#
#uid/pw: dockeradmin/dockeradmin


# add user's local npm bin directory to search path
export PATH=$(${NPM} bin):${PATH}

if [ -f Dockerfile ] 
then
	sudo docker tag ${TAG} ${REGISTRY}/${TAG}
	sudo docker tag ${TAG} ${REGISTRY}/${REPOSITORY}:latest

	sudo docker push ${REGISTRY}/${TAG}
	sudo docker push ${REGISTRY}/${REPOSITORY}:latest
else
	echo "no package.json, exiting"
	exit 1
fi
