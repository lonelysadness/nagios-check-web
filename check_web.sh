#!/bin/bash

# Check the availability of a website on specified ports (default HTTP: 80, HTTPS: 443)

# Default ports
DEFAULT_HTTP_PORT=80
DEFAULT_HTTPS_PORT=443

# Help message
display_help() {
    echo "Usage: $0 [options] <URL>"
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -p, --http-port   Specify HTTP port (default: $DEFAULT_HTTP_PORT)"
    echo "  -s, --https-port  Specify HTTPS port (default: $DEFAULT_HTTPS_PORT)"
    echo "Example:"
    echo "  $0 --http-port 8080 --https-port 8443 www.example.com"
}

# Function to check availability on a specific port
check_port() {
    local url=$1
    local port=$2
    local protocol=$3

    if timeout 10 bash -c "echo > /dev/tcp/$url/$port" 2>/dev/null; then
        echo "OK - $protocol connection successful on $url:$port"
        return 0
    else
        echo "CRITICAL - $protocol connection failed on $url:$port"
        return 2
    fi
}

# Parse arguments
http_port=$DEFAULT_HTTP_PORT
https_port=$DEFAULT_HTTPS_PORT
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            display_help
            exit 0
            ;;
        -p|--http-port)
            http_port=$2
            shift 2
            ;;
        -s|--https-port)
            https_port=$2
            shift 2
            ;;
        *)
            URL=$1
            shift
            ;;
    esac
done

# Checking if URL is provided
if [[ -z "${URL:-}" ]]; then
    echo "Error: URL not provided."
    display_help
    exit 3
fi

# Check HTTP
check_port $URL $http_port "HTTP"
status_http=$?

# Check HTTPS
check_port $URL $https_port "HTTPS"
status_https=$?

# Determine overall status
if [ $status_http -eq 0 ] && [ $status_https -eq 0 ]; then
    exit 0
elif [ $status_http -eq 2 ] || [ $status_https -eq 2 ]; then
    exit 2
else
    exit 3
fi

