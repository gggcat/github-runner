FROM python:3.8-slim

#ENV RUNNER_VERSION=2.164.0

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y --no-install-recommends curl && \
    apt-get install -y --no-install-recommends wget && \
    apt-get install -y --no-install-recommends jq && \
    apt-get install -y --no-install-recommends docker.io && \
    apt-get install -y --no-install-recommends docker-compose && \
    echo "*** INSTALLED: ubuntu modules ***"

RUN useradd -m actions && \
    cd /home/actions && mkdir actions-runner && cd actions-runner  && \
    export RUNNER_URL=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.assets[].browser_download_url | select(. | contains("linux-x64"))') && \
    wget ${RUNNER_URL} && \
    export RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | jq -r '.assets[].name | select(. | contains("linux-x64"))') && \
    tar xzf ${RUNNER_VERSION} && \
    #wget https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    #tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    echo "*** INSTALLED: GitHub actions modules ***"

WORKDIR /home/actions/actions-runner

RUN chown -R actions ~actions && /home/actions/actions-runner/bin/installdependencies.sh 

#USER actions

COPY entrypoint.sh .
ENTRYPOINT ["bash", "entrypoint.sh"]
