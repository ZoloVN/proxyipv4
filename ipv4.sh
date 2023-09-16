#!/bin/bash

# Number of proxies to create
NUM_PROXIES=20

# Base port number
BASE_PORT=3000

# Directory to store proxy configuration files
PROXY_DIR=/etc/20proxies

# Create the proxy directory if it doesn't exist
mkdir -p $PROXY_DIR

# Install required packages (assuming you're using a package manager like apt or yum)
# Modify the package installation commands based on your distribution
# Example for Ubuntu:
# apt-get update
# apt-get install -y squid

# Configuration file template for Squid proxy
cat > $PROXY_DIR/squid.conf.template <<EOL
http_port PORT
acl localnet src 0.0.0.1-0.255.255.255
http_access allow localnet
http_access deny all
EOL

# Loop to create proxy configurations
for ((i=1; i<=NUM_PROXIES; i++)); do
    PORT=$((BASE_PORT + i))
    CONFIG_FILE="$PROXY_DIR/proxy-$i.conf"

    # Create a copy of the template and replace PORT with the actual port number
    sed "s/PORT/$PORT/g" $PROXY_DIR/squid.conf.template > $CONFIG_FILE

    # Start Squid with the new configuration file
    squid -f $CONFIG_FILE -N -d 1
done

# Restart Squid to apply changes
systemctl restart squid

echo "Proxies have been created on ports $((BASE_PORT + 1)) to $((BASE_PORT + NUM_PROXIES))."
