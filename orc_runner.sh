#!/bin/bash

REPOSITORIES=$(cat repos.json | jq -r '.[].repository_name')

for REPOSITORY_NAME in ${REPOSITORIES}; do 
    # repository have runnners?
    HAVE_RUNNERS=$(curl -s -H "accept: application/vnd.github.antiope-preview+json" \
        -H "authorization: token ${GITHUB_TOKEN}" \
        https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/actions/runners \
        | jq -r '.total_count')

    # repository dont have runnners. create it. (but its never use.)
    echo "${REPOSITORY_NAME} have runners (${HAVE_RUNNERS})"
    if [ ${HAVE_RUNNERS} = "0" ]; then
        RUNNER_NAME="${REPOSITORY_NAME}-REG"
        echo "regist 1st runner at ${REPOSITORY_NAME}"
        docker-compose run runner ${GITHUB_USER} ${REPOSITORY_NAME} ${GITHUB_TOKEN} ${RUNNER_NAME} "1"
        docker-compose down
    elif [ ${HAVE_RUNNERS} = "1" ]; then
        # add repository
        echo "regist runner at ${REPOSITORY_NAME} ..."
        bash orc.sh ${GITHUB_TOKEN} ${GITHUB_USER} ${REPOSITORY_NAME}
    else
        echo "${REPOSITORY_NAME} already have runners"
    fi
done
