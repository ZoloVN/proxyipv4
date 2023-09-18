#!/bin/bash

# Số lượng proxy bạn muốn tạo
proxy_count=10

# Port proxy ban đầu
start_port=5000

# Tạo thư mục để lưu cấu hình
mkdir -p /etc/squid/proxies

for ((i = 1; i <= proxy_count; i++)); do
  proxy_port=$((start_port + i))
  proxy_user="user$i"
  proxy_pass="pass$i"

  # Tạo tệp cấu hình cho proxy
  cat <<EOL >"/etc/squid/proxies/proxy$i.conf"
auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/passwords
auth_param basic children 5
auth_param basic realm Squid proxy-caching web server
auth_param basic credentialsttl 2 hours
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_port $proxy_port
EOL

  # Tạo tệp mật khẩu cho proxy
  printf "${proxy_user}:${proxy_pass}\n" >>/etc/squid/passwords

  echo "Created proxy$i on port $proxy_port"
done

# Khởi động lại dịch vụ Squid để áp dụng cấu hình mới
systemctl restart squid

# Hiển thị danh sách các proxy đã tạo
echo "Danh sách các proxy đã tạo:"
for ((i = 1; i <= proxy_count; i++)); do
  proxy_port=$((start_port + i))
  proxy_user="user$i"
  proxy_pass="pass$i"
  echo "Proxy $i: http://139.180.215.12:$proxy_port, User: $proxy_user, Password: $proxy_pass"
done
