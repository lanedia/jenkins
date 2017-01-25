#!/bin/bash
set -x
cd ${MODULE_NAME}

echo "Executing build for ${MODULE_NAME} in ${REPO_URL}"
#GITREV=1
GITREV=`git rev-list HEAD|wc -l`
REPOSITORY=asa/${MODULE_NAME}
TAG=${REPOSITORY}:${GITREV}


NPM=$(which npm 2>/dev/null)
test -n "${NPM}" -a -x "${NPM}" || { echo "${NPM:-npm} not found or not executable. Exiting."; exit 1; }

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
set -ue

# add user's local npm bin directory to search path
export PATH=$(${NPM} bin):${PATH}

if [ ! -f Dockerfile ]
then
	exit 0
fi

if [ -f package.json ] 
then
	#sudo docker build -t ${MODULE_NAME} .
	sudo docker build --no-cache -t ${TAG} -f ./Dockerfile .
fi



