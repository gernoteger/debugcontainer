#!/usr/bin/env bash

set -euo pipefail


function message {
    echo ""
    echo "---------------------------------------------------------------"
    echo $1
    echo "---------------------------------------------------------------"
}

message " Check if we're in Github Actions or local run "
if [ -n "${GITHUB_ACTIONS:-}" ]; then
    echo " Github Actions. Image should already be built."
    docker images
    if [ -z "$(docker images -q gernoteger/debugcontainer:testing 2> /dev/null)" ]; then
        echo "Docker image gernoteger/debugcontainer:testing not found. Exiting."
        exit 1
    fi
else
    echo " Local run. Build image "
    docker build -t gernoteger/debugcontainer:testing .
fi


mkdir -p target/testarea
pushd testarea

message " Cleaning up from previous test run "
docker ps -aq --filter "name=debugcontainer-tests" | grep -q . && docker stop debugcontainer-tests && docker rm -f debugcontainer-tests

message " Start container normally "
docker run -d --rm --name debugcontainer-tests -p 8080:8080 -p 8443:8443 -t gernoteger/debugcontainer:testing
# sleep 5 # why?


message " Stop container "
docker stop debugcontainer-tests
# sleep 5 # why?

popd
rm -rf target/testarea
message "DONE"