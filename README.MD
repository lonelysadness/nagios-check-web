# Nagios Website Availability Probe Script

## Overview
This script is designed for Nagios monitoring systems to check the availability of a website or service on specified ports. It supports both HTTP and HTTPS protocols and allows specifying custom ports and timeout duration.

## Features
- Checks website availability on specified HTTP and HTTPS ports.
- Customizable port settings for HTTP and HTTPS.
- Configurable timeout for connection attempts.
- Supports both domain names and IP addresses.

## Prerequisites
- Bash shell environment
- Nagios monitoring system (optional for standalone use)

## Installation
1. Download the script to your Nagios plugin directory, typically `/usr/local/nagios/libexec/`:
```Bash
wget -O /usr/local/nagios/libexec/check_web.sh https://raw.githubusercontent.com/lonelysadness/nagios-check-web/main/check_web.sh
```

2. Make the script executable:
```Bash
chmod +x /usr/local/nagios/libexec/check_web.sh
```


## Usage
Run the script with the following syntax:

```Bash
./check_web.sh [options] <URL or IP>
```


### Options
- `-h, --help`: Show help message.
- `-p, --http-port`: Specify the HTTP port (default: 80).
- `-s, --https-port`: Specify the HTTPS port (default: 443).
- `-t, --timeout`: Specify the timeout in seconds (default: 10).

### Examples
- Check availability of `www.example.com` on default ports:
```Bash
./check_web.sh www.example.com
```

- Check availability of `192.168.1.1` on custom ports with a 5-second timeout:
```Bash
./check_web.sh -p 8080 -s 8443 -t 5 192.168.1.1
```


## Integration with Nagios
1. Define a command in your Nagios configuration:

```Bash
define command {
    command_name check_web
    command_line $USER1$/check_web.sh -p $ARG1$ -s $ARG2$ -t $ARG3$ $ARG4$
}
```

2. Use the command in your service definitions:

```Bash
define service {
    use generic-service
    host_name example-host
    service_description Check Website
    check_command check_web!8080!8443!10!www.example.com
}
```

## Contributing
Contributions to this script are welcome. Please send pull requests or open issues for suggestions and feedback.

