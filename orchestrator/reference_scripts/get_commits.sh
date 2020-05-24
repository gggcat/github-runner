#!/bin/bash

# get the date format in the format the github api wants
function past_minutes_ago () {
    PAST_MINUTE=$1

    #echo $(date --iso-8601=seconds --date='5 minutes ago' | awk -F'+' '{print $1}')
    echo $(date --iso-8601=seconds --date="${PAST_MINUTE} minutes ago" | awk -F'+' '{print $1}')
}

function check_runner_status () {
    REPOSITORY_NAME=$1

    COMMIT_STATUS=$(curl -s -H "accept: application/vnd.github.antiope-preview+json" \
        -H "authorization: token ${GITHUB_TOKEN}" \
        https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/commits \
        -o /dev/null -w '%{http_code}\n' -s)
    echo ${COMMIT_STATUS}
}

function get_commits () {
    REPOSITORY_NAME=$1
    PAST_MINUTE=$2

    COMMIT_STATUS=$( check_runner_status ${REPOSITORY_NAME} )
    echo ${COMMIT_STATUS}
    if [ ${COMMIT_STATUS} = "200" ]; then
        
        #COMMITS=$(curl -s -H "accept: application/vnd.github.antiope-preview+json" \
        #    -H "authorization: token ${GITHUB_TOKEN}" \
        #    https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/commits?since="$( past_minutes_ago ${PAST_MINUTE} )Z" \
        #    | jq -r '.[].sha')
        COMMITS=$(curl -s -H "accept: application/vnd.github.antiope-preview+json" \
            -H "authorization: token ${GITHUB_TOKEN}" \
            https://api.github.com/repos/${GITHUB_USER}/${REPOSITORY_NAME}/commits/HEAD \
            | jq -r '.sha')
        echo ${COMMITS}
    else
        echo "Getting commits from the last 5 minutes ... no commits"
        exit 0
    fi
}

REPOSITORY_NAME="test_repo"
get_commits ${REPOSITORY_NAME} "18000"