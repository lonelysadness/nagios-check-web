#!/bin/bash

# Nagios probe script to check the availability of a website on specified ports

DEFAULT_HTTP_PORT=80
DEFAULT_HTTPS_PORT=443

display_help() {
    echo "Usage: $0 [options] <URL or IP>"
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -p, --http-port   Specify HTTP port (default: $DEFAULT_HTTP_PORT)"
    echo "  -s, --https-port  Specify HTTPS port (default: $DEFAULT_HTTPS_PORT)"
    echo "  -t, --timeout     Specify timeout in seconds (default: 10)"
    echo "Example:"
    echo "  $0 -p 8080 -s 8443 -t 5 www.example.com"
    echo "  $0 -p 8080 -s 8443 -t 5 192.168.1.1"
}

check_port() {
    local url=$1
    local port=$2
    local protocol=$3
    local start_time=$(date +%s.%N)
    if timeout $timeout_duration bash -c "echo > /dev/tcp/$url/$port" 2>/dev/null; then
        local status="OK"
        local result_code=0
    else
        local status="CRITICAL"
        local result_code=2
    fi
    local end_time=$(date +%s.%N)
    local elapsed=$(echo "$end_time - $start_time" | bc)
    printf "%s - %s connection on %s:%s | 'time_%s'=%.6fs\n" "$status" "$protocol" "$url" "$port" "$protocol" "$elapsed"
    return $result_code
}

parse_arguments() {
    local OPTIND
    while getopts ":hp:s:t:" opt; do
        case ${opt} in
            h ) display_help; exit 0 ;;
            p ) http_port=$OPTARG ;;
            s ) https_port=$OPTARG ;;
            t ) timeout_duration=$OPTARG ;;
            \? ) echo "Invalid Option: -$OPTARG" >&2; exit 1 ;;
        esac
    done
    shift $((OPTIND -1))
    URL=$1
}

http_port=$DEFAULT_HTTP_PORT
https_port=$DEFAULT_HTTPS_PORT
timeout_duration=10
parse_arguments "$@"

if [[ -z "${URL:-}" ]]; then
    echo "Error: URL or IP not provided." >&2
    display_help
    exit 3
fi

http_result=$(check_port $URL $http_port "HTTP")
status_http=$?

https_result=$(check_port $URL $https_port "HTTPS")
status_https=$?

# Display the results
[[ $status_http -eq 2 ]] && echo "$http_result"
[[ $status_https -eq 2 ]] && echo "$https_result"
[[ $status_http -eq 0 ]] && echo "$http_result"
[[ $status_https -eq 0 ]] && echo "$https_result"

# Exit with the appropriate code
if [ $status_http -ne 0 ] || [ $status_https -ne 0 ]; then
    exit 2
fi

exit 0

