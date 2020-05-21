FROM python:3.8-slim

ENV RUNNER_VERSION=2.164.0

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y --no-install-recommends curl && \
    apt-get install -y --no-install-recommends wget && \
    apt-get install -y --no-install-recommends jq && \
    apt-get install -y --no-install-recommends docker.io && \
    apt-get install -y --no-install-recommends docker-compose && \
    apt-get install -y --no-install-recommends cron && \
    echo "*** INSTALLED: ubuntu modules ***"

WORKDIR /home/orchestrator

# Cron
RUN echo "*/5 * * * * root cd /home/orchestrator && bash orc_runner.sh" > /etc/cron.d/runner-cron && \
    chmod 0644 /etc/cron.d/runner-cron && \
    crontab /etc/cron.d/runner-cron && \
    touch /var/log/cron.log && \
    echo "*** INSTALLED: cron settings ***"

COPY docker-compose.yml .
COPY orc_runner.sh .
COPY orchestrator.Dockerfile .
COPY runner.Dockerfile .
COPY orc.sh .
COPY repos.json .
#ENTRYPOINT ["bash", "-c"]
CMD ["cron", "-f"]