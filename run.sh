#!/bin/bash

sudo apt update && sudo apt upgrade -y

sudo apt install shadowsocks-libev -y

ask_for_input() {
    local prompt="$1"
    local default_value="$2"
    local var
    while true; do
        if [ -n "$default_value" ]; then
            read -rp "$prompt [$default_value]: " var
            var="${var:-$default_value}"
        else
            read -rp "$prompt: " var
        fi

        if [ -n "$var" ]; then
            echo "$var"
            return
        else
            echo "Error: the input cannot be empty."
        fi
    done
}

#  Shadowsocks cred's
server_ip=$(ask_for_input "Enter the IP of the server")
server_port=$(ask_for_input "Enter server port." "8388.")
password=$(ask_for_input "Enter password.")
encryption_method=$(ask_for_input "Enter encryption method" "aes-256-cfb")

# SSH cust port
ssh_port=$(ask_for_input "Enter the port for SSH (default is 22)." "22")

# creatin' config Shadowsocks
config_json=$(cat <<EOF
{
    "server":"$server_ip",
    "server_port":$server_port,
    "password":"$password",
    "timeout":300,
    "method":"$encryption_method",
    "fast_open": false
}
EOF
)

# saving conf Shadowsocks
config_path="/etc/shadowsocks-libev/config.json"
echo "$config_json" | sudo tee "$config_path" > /dev/null

# UFW setup
sudo apt install ufw -y

# Deletion of all existing rules
sudo ufw --force reset

# necessary prots
sudo ufw allow $ssh_port/tcp comment "SSH"
sudo ufw allow $server_port/tcp comment "Shadowsocks TCP"
sudo ufw allow $server_port/udp comment "Shadowsocks UDP"

# Adding false open ports for confusion
fake_ports=(2459 2362 5624 52346 5422)
for port in "${fake_ports[@]}"; do
    sudo ufw allow $port/tcp comment "Fake port"
    sudo ufw allow $port/udp comment "Fake port"
done

sudo ufw --force enable

sudo sed -i "s/^#Port 22/Port $ssh_port/" /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo systemctl restart shadowsocks-libev
sudo systemctl enable shadowsocks-libev

# Conclusion
echo "Installation complete!"
echo "SSH Port: $ssh_port"
echo "Shadowsocks port: $server_port"
echo "The password is Shadowsocks: $password"
echo "Encryption Method: $encryption_method"
echo "False ports: ${fake_ports[*]}"