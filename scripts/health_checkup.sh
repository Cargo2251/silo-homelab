#!/usr/bin/env bash

log() {
  local LOG="/var/log/health_check.log"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >>"$LOG"
  if [[ "$VERBOSE" == true ]]; then
    echo "$1"
  fi
}

print_status() {
  if [[ "$VERBOSE" == false ]]; then
    printf "%-15s %s\n" "$1" "$2"
  fi
}

default_URLs=urls.conf
count_on=0
count_off=0
VERBOSE=false

GREEN=$'\033[0;32m'
RED=$'\033[0;31m'
RESET=$'\033[0m'

while [[ $# -gt 0 ]]; do
  case "$1" in
  --help)
    echo -e "Health Check script that checks at DNS,TCP,TLS level.\n
  --verbose: turns on the verbose mode allowing the script to log on terminal it's actions.\n
  --file: allows to set a path for the config file where the URL's will be pulled from (one URL per line)"
    exit
    ;;
  --verbose)
    VERBOSE=true
    shift
    ;;
  --file)
    FILE="$2"
    shift 2
    ;;
  *)
    echo "Unknown Flag: --help, --verbose, --file"
    exit 1
    ;;
  esac
done

if [[ ! -f "$default_URLs" ]]; then
  echo "Config file not found: $default_URLs"
  exit 1
fi

site_URLs=()

while IFS= read -r line; do
  if [[ -z $line ]]; then
    continue
  fi
  site_URLs+=("$line")
done <"${FILE:-$default_URLs}"

if [[ "$VERBOSE" == false ]]; then
  printf '%-15s %s\n' "URL" "STATUS"
  printf '%-15s %s\n' "--------" "--------"
fi

for x in "${site_URLs[@]}"; do
  resolved_ip=$(host "$x" | awk '/has address/ {print $NF}') # DNS Resolution - query the domain's A record and extract the IP.

  if [[ -z "$resolved_ip" ]]; then # If resolved_ip is empty, that means that no IP has been logged.
    log "DNS Failed for ${x}"
    print_status "${x}" "${RED}OFFLINE${RESET}"
    ((count_off++))
    continue
  fi

  http_code=$(curl --connect-timeout 5 -o /dev/null -s -w "%{http_code}" "https://$x") # TCP handshake, TLS negotiation, HTTP request and response.
  exit_code=$?

  case "$exit_code" in # Check if connection failed at TCP (7) or DNS (6)
  6)
    log "Exit code 6: ${x} could not be resolved"
    print_status "${x}" "${RED}OFFLINE${RESET}"
    ((count_off++))
    continue
    ;;
  7)
    log "Exit code 7: Failed to connect to ${x}"
    print_status "${x}" "${RED}OFFLINE${RESET}"
    ((count_off++))
    continue
    ;;
  esac

  case "$http_code" in # Evaluate the HTTP reponse code.
  4* | 5*)
    log "HTTP 4/5** on ${x} ${http_code} found, check it"
    print_status "${x}" "${RED}OFFLINE${RESET}"
    ((count_off++))
    ;;
  *)
    log "${x} resolved to ${resolved_ip} - HTTP ${http_code}"
    ((count_on++))
    print_status "${x}" "${GREEN}ONLINE${RESET}"
    ;;
  esac
done

printf "%-15s %s\n" "${GREEN}Healthy:${RESET} ${count_on}" "${RED}Failed:${RESET} ${count_off}"
