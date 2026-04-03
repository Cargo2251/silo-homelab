#!/usr/bin/env bash

log() {
  local LOG="/var/log/health_check.log"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >>"$LOG"
}

GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
RESET=$'\033[0m'

site_URLs=("home.cargolab.dev" "dozzle.cargolab.dev" "dockge.cargolab.dev" "nextcloud.cargolab.dev" "grafana.cargolab.dev" "vault.cargolab.dev" "sync.cargolab.dev" "npm.cargolab.dev" "speedtest.cargolab.dev" "kuma.cargolab.dev")

printf '%-15s %s\n' "URL" "STATUS"
printf '%-15s %s\n' "--------" "--------"

for x in "${site_URLs[@]}"; do
  resolved_ip=$(host "$x" | awk '/has address/ {print $NF}') # DNS Resolution - query the domain's A record and extract the IP.

  if [[ -z "$resolved_ip" ]]; then # If resolved_ip is empty, that means that no IP has been logged.
    log "DNS Failed for ${x}"
    continue
  fi

  http_code=$(curl --connect-timeout 5 -o /dev/null -s -w "%{http_code}" "https://$x") # TCP handshake, TLS negotiation, HTTP request and response.
  exit_code=$?

  case "$exit_code" in # Check if connection failed at TCP (7) or DNS (6)
  6)
    log "Exit code 6: ${x} could not be resolved"
    continue
    ;;
  7)
    log "Exit code 7: Failed to connect to ${x}"
    continue
    ;;
  esac

  case "$http_code" in # Evaluate the HTTP reponse code.
  4* | 5*)
    log "HTTP 4/5** on ${x} ${http_code} found, check it"
    printf "%-15s %s\n" "${x}" "${RED}OFFLINE${RESET}"
    ;;
  *)
    log "${x} resolved to ${resolved_ip} - HTTP ${http_code}"
    printf "%-15s %s\n" "${x}" "${GREEN}ONLINE${RESET}"
    ;;
  esac
done
