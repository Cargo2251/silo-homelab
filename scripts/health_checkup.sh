#!/bin/bash

CONTAINER_NAME=test-web
COMPOSE_DIR=~/docker/test-web
MAIN_LOG=~/homelab_monitor.log

if [ "$( docker container inspect -f '{{.State.Running}}' $CONTAINER_NAME)" = "true" ]; then
echo "$(date) - The $CONTAINER_NAME is running" >> $MAIN_LOG
exit
else
echo "$(date) - The $CONTAINER_NAME is not running, attempting to restart" >> $MAIN_LOG
cd $COMPOSE_DIR; docker compose up -d
echo "Ran compose up, container should be up shortly" >> $MAIN_LOG
fi
