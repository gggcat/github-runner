#!/bin/bash

REPOSITORY_NAME=$1

function offline_runners () {
    REPOSITORY_NAME=$1
    OFFLINE_RUNNER_ID=$( curl -s -H "accept: application/vnd.github.antiope-preview+json" \
            -H "authorization: token ${GITHUB_TOKEN}" \
            https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/actions/runners \
            | jq -r '.runners[] | select( .status == "offline" and (.name | contains("-RUN")) ) | .id' )

    echo ${OFFLINE_RUNNER_ID}
}

# DELETE /repos/:owner/:repo/actions/runners/:runner_id
function delete_runner () {
    REPOSITORY_NAME=$1
    RUNNER_ID=$2
    curl -s -H "accept: application/vnd.github.antiope-preview+json" \
            -H "authorization: token ${GITHUB_TOKEN}" \
            -X DELETE \
            https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/actions/runners/${RUNNER_ID}
}


SELF_HOSTED_REPOSITORIES="repositories.jsonl"
REPOSITORIES=$(cat ${SELF_HOSTED_REPOSITORIES} | jq --slurp -r '.[].repository_name')

for REPOSITORY_NAME in ${REPOSITORIES}; do 
    for RUNNER_ID in $( offline_runners ${REPOSITORY_NAME} ); do
        # clean offiline jobs
        echo "DELETE RUNNER: ${RUNNER_ID}"
        delete_runner ${REPOSITORY_NAME} ${RUNNER_ID}
    done
done
