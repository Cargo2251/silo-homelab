#!/usr/bin/env bash

log() {
  local LOG="/var/log/health_check.log"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >>$LOG
}

site_URLs=("home.cargolab.dev" "dozzle.cargolab.dev" "dockge.cargolab.dev" "nextcloud.cargolab.dev" "grafana.cargolab.dev" "vault.cargolab.dev" "sync.cargolab.dev" "npm.cargolab.dev" "speedtest.cargolab.dev" "kuma.cargolab.dev")

for x in "${site_URLs[@]}"; do
  rezolved_ip=$(host "$x" | awk '/has address/ {print $NF}') # Checks each URL and outputs only the IP address from them.

  if [[ -z "$rezolved_ip" ]]; then # If rezolved_ip is empty, that means that no IP has been logged.
    log "DNS Failed for ${x}"
    continue
  fi

  http_code=$(curl --connect-timeout 5 -o /dev/null -s -w "%{http_code}" "https://$x") # Checks for Exit code 6 / 7 whilst also outputing the HTTP code
  exit_code=$?

  case "$exit_code" in # Case block for the exit codes
  6)
    log "Exit code 6: ${x} could not be resolved"
    continue
    ;;
  7)
    log "Exit code 7: Failed to connect to ${x}"
    continue
    ;;
  esac

  case "$http_code" in # Case block for the http_codes
  4* | 5*)
    log "HTTP 4/5** on ${x} ${http_code} found, check it"
    ;;
  *)
    log "${x} resolved to ${rezolved_ip} - HTTP ${http_code}"
    ;;
  esac

done
