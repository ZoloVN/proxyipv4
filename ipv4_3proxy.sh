#!/bin/bash

# Install required packages
sudo apt-get update
sudo apt-get install -y gcc make nano git

# Clone 3proxy repository
git clone https://github.com/z3APA3A/3proxy.git
cd 3proxy

# Build and install 3proxy
make -f Makefile.Linux
sudo make -f Makefile.Linux install

# Create a directory for 3proxy configuration
sudo mkdir -p /usr/local/etc/3proxy

# Create a user and group for 3proxy
sudo groupadd proxy
sudo useradd -g proxy -c "3proxy User" -s /bin/false -d /usr/local/etc/3proxy proxy

# Create a basic 3proxy configuration file
cat <<EOL | sudo tee /usr/local/etc/3proxy/3proxy.cfg
daemon
maxconn 200
nserver 8.8.8.8
nserver 8.8.4.4
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
flush

auth iponly
allow * 0.0.0.0/0
proxy -n -a -p8080 -i127.0.0.1
EOL

# Create a script to generate proxy configurations
cat <<EOL | sudo tee /usr/local/etc/3proxy/generate_proxy_configs.sh
#!/bin/bash

# Number of proxies to generate
num_proxies=20

# Base port number
base_port=30000

# Clear previous proxy configurations
rm -f /usr/local/etc/3proxy/proxy_*.cfg

for ((i=1; i<=num_proxies; i++)); do
  proxy_port=\$((base_port + i))
  cat <<CONFIG > /usr/local/etc/3proxy/proxy_\${proxy_port}.cfg
daemon
maxconn 200
nserver 8.8.8.8
nserver 8.8.4.4
nscache 65536
timeouts 1 5 30 60 180 1800 15 60
setgid 65535
setuid 65535
flush

auth iponly
allow * 0.0.0.0/0
proxy -n -a -p\${proxy_port} -i127.0.0.1
CONFIG
done
EOL

# Make the script executable
sudo chmod +x /usr/local/etc/3proxy/generate_proxy_configs.sh

# Generate the proxy configurations
sudo /usr/local/etc/3proxy/generate_proxy_configs.sh

# Start 3proxy
sudo /usr/local/etc/3proxy/3proxy /usr/local/etc/3proxy/3proxy.cfg
