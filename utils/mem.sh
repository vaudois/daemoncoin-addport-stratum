#!/usr/bin/env bash

PHP_CLI='php -d max_execution_time=120'

DIR=/home/crypto-data/yiimp/site/web/
cd ${DIR}

date
echo started in ${DIR}

while true; do
${PHP_CLI} runconsole.php cronjob/runMem
sleep 90
done
exec bash
