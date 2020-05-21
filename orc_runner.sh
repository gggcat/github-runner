#!/bin/bash

REPOSITORIES=$(cat repos.json | jq '.[].repository_name')

for REPOSITORY_NAME in ${REPOSITORIES}; do 
    echo "Orchestration ${REPOSITORY_NAME} ..."
    bash orc.sh ${GITHUB_TOKEN} ${GITHUB_USER} ${REPOSITORY_NAME}
done