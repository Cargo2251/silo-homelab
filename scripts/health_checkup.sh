#!/bin/bash

CONTAINERS_NAMES=("npm" "diun" "nextcloud" "dockge" "dozzle" "couchdb" "uptime-kuma" "vaultwarden" "homepage" "speedtest-tracker")
COMPOSE_DIR=~/docker
MAIN_LOG=~/homelab_monitor.log

for CONTAINER in "${CONTAINERS_NAMES[@]}"; do

    IS_RUNNING=$(docker container inspect -f '{{.State.Running}}' "$CONTAINER" 2>/dev/null)

    if [ "$IS_RUNNING" = "true" ]; then
        echo "$(date) - The ${CONTAINER} is running" >> "$MAIN_LOG"
    else
        echo "$(date) - The ${CONTAINER} is not running, attempting to restart" >> "$MAIN_LOG"
        cd "$COMPOSE_DIR" || exit 1;

        if ! docker compose up -d; then
            echo "$(date) - Restart failed! Grabbing logs.." >> "$MAIN_LOG"

            docker logs "$CONTAINER" --tail 50 > ~/homelab_${CONTAINER}_error.log
        else
            echo "$(date) - Ran compose up, container should be up shortly." >> "$MAIN_LOG"

        fi
    fi
done