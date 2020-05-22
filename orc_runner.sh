#!/bin/bash

REPOSITORIES=$(cat repos.json | jq '.[].repository_name')

for REPOSITORY_NAME in ${REPOSITORIES}; do 
    # repository have runnners?
    HAVE_RUNNER=$(curl -s -H "accept: application/vnd.github.antiope-preview+json" \
        -H "authorization: token ${GITHUB_TOKEN}" \
        https://api.github.com/repos/${GITHUB_USER}/test_repo/runners \
        -o /dev/null -w '%{http_code}\n' -s)

    # repository dont have runnners. create it. (but its never use.)
    echo "${REPOSITORY_NAME} have runner config: code=${HAVE_RUNNER}"
    if [ ${HAVE_RUNNER} = "404" ]; then
        RUNNER_NAME="${REPOSITORY_NAME}"
        echo "docker-compose run runner ${GITHUB_USER} ${REPOSITORY_NAME} ${GITHUB_TOKEN} ${RUNNER_NAME} \"1\""
        docker-compose run runner ${GITHUB_USER} ${REPOSITORY_NAME} ${GITHUB_TOKEN} ${RUNNER_NAME} "1"
        sleep 60
        docker-compose down
    fi

    # add repository
    echo "Orchestration ${REPOSITORY_NAME} ..."
    bash orc.sh ${GITHUB_TOKEN} ${GITHUB_USER} ${REPOSITORY_NAME}
done
