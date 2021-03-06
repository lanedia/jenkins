#!/bin/bash
set -x

echo "Executing npm publish ${MODULE_NAME}"

cd ${MODULE_NAME}
NPM=$(which npm 2>/dev/null)
test -n "${NPM}" -a -x "${NPM}" || { echo "${NPM:-npm} not found or not executable. Exiting."; exit 1; }

# Exit immediately if a command exits with a non-zero status.
# Treat unset variables as an error when substituting.
set -ue

# add user's local npm bin directory to search path
export PATH=$(${NPM} bin):${PATH}

if [ -f package.json ] 
then
	npm config set registry http://npm.tecnotree.com
	npm publish
else
	echo "no package.json, exiting"
	exit 1
fi
