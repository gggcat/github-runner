

CRON_CONFIG=/etc/cron.d/runner-cron
CRON_LOG=/var/log/cron.log

env > ${CRON_CONFIG}
echo "" >> ${CRON_CONFIG}
echo "*/1 * * * * root cd /home/orchestrator && bash orc_runner.sh >> ${CRON_LOG}" >> ${CRON_CONFIG}
chmod 0644 ${CRON_CONFIG}
crontab ${CRON_CONFIG}
touch ${CRON_LOG}

exec "$@"