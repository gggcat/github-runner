CRON_CONFIG=/etc/cron.d/runner-cron
CRON_LOG=/var/log/cron.log

# make repositories.jsonl
bash get_repositories.sh
sleep 2.0
bash clean_runner.sh
sleep 2.0

env > ${CRON_CONFIG}
echo "" >> ${CRON_CONFIG}
# update repositories.jsonl
echo "0 0 * * 6 root cd /home/orchestrator && bash get_repositories.sh >> ${CRON_LOG}" >> ${CRON_CONFIG}
# clean runners
echo "0 0 * * 6 root cd /home/orchestrator && bash clean_runner.sh >> ${CRON_LOG}" >> ${CRON_CONFIG}
# do self-hosted runners
echo "*/10 * * * * root cd /home/orchestrator && bash orchestrator.sh >> ${CRON_LOG}" >> ${CRON_CONFIG}
chmod 0644 ${CRON_CONFIG}
crontab ${CRON_CONFIG}
touch ${CRON_LOG}

# do cron
cron && tail -f ${CRON_LOG}
