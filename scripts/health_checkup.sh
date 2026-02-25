#!/bin/bash

CONTAINER_NAME=npm
COMPOSE_DIR=~/docker/npm
MAIN_LOG=~/homelab_monitor.log

if [ "$( docker container inspect -f '{{.State.Running}}' $CONTAINER_NAME)" = "true" ]; then
    echo "$(date) - The $CONTAINER_NAME is running" >> "$MAIN_LOG"
    exit
else
    echo "$(date) - The $CONTAINER_NAME is not running, attempting to restart" >> "$MAIN_LOG"
    cd $COMPOSE_DIR || exit 1; docker compose up -d

    if [ $? -ne 0 ]; then
        echo "$(date) - Restart failed! Grabbing logs.." >> "$MAIN_LOG"

        docker logs "$CONTAINER_NAME" --tail 50 > ~/homelab_${CONTAINER_NAME}_error.log
    else
        echo "$(date) - Ran compose up, container should be up shortly."

    fi
fi