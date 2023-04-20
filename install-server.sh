#!/bin/bash

echo "Select an option"
select opt in install update_config uninstall quit
do
  case $opt in
    install)
      echo "Enter your VPS IP and press enter"
      read -r -e VPS_IP
      echo "Enter domain and press enter"
      read -r -e SITE
      echo "Enter port number 1-65535 Or type random for random port then press enter"
      read -r -e PORT
      if (( "$PORT" < 1 || "$PORT" > 65535)); then
        if [ "$PORT" != "random" ]
        then
          echo "Invalid port number"
          exit
        else
          PORT=$((1024 + $RANDOM))
        fi
      fi

      #generate passwords
      SHADOWSOCKS_PASSWORD=$(openssl rand -base64 24)
      SHADOWTLS_PASSWORD=$(openssl rand -base64 24)

      mkdir -p $HOME/sing-box
      wget https://github.com/SagerNet/sing-box/releases/download/v1.2.4/sing-box-1.2.4-linux-amd64.tar.gz
      tar -xf sing-box-1.2.4-linux-amd64.tar.gz
      cp sing-box-1.2.4-linux-amd64/sing-box "${HOME}/sing-box"
      rm -rf sing-box-1.2.4-linux-amd64.tar.gz sing-box-1.2.4-linux-amd64
      cat << EOF > "${HOME}/sing-box/config.json"
{
	"log": {
		"disabled": true
	},
	"dns": {
		"servers": [
			{
				"address": "tls://8.8.8.8"
			}
		]
	},
	"inbounds": [
		{
			"type": "shadowtls",
			"listen": "::",
			"listen_port": ${PORT},
			"version": 3,
			"users": [
				{
					"name": "sekai",
					"password": "${SHADOWTLS_PASSWORD}"
				}
			],
			"handshake": {
				"server": "${SITE}",
				"server_port": 443
			},
			"detour": "shadowsocks-in"
		},
		{
			"type": "shadowsocks",
			"tag": "shadowsocks-in",
			"listen": "127.0.0.1",
			"network": "tcp",
			"method": "chacha20-ietf-poly1305",
			"password": "${SHADOWSOCKS_PASSWORD}"
		}
	],
	"outbounds": [
		{
			"type": "direct"
		},
		{
			"type": "dns",
			"tag": "dns-out"
		}
	],
	"route": {
		"rules": [
			{
				"protocol": "dns",
				"outbound": "dns-out"
			}
		]
	}
}
EOF
      cat << EOF > "/etc/systemd/system/sing-box.service"
[Unit]
Description=sing-box service
Documentation=https://sing-box.sagernet.org
After=network.target nss-lookup.target

[Service]
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE CAP_DAC_READ_SEARCH
ExecStart=${HOME}/sing-box/sing-box run -c ${HOME}/sing-box/config.json
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF
      systemctl daemon-reload
      systemctl enable sing-box.service
      systemctl start sing-box.service
			echo "Done!"
			echo "Copy this content for client config.json file"
      cat << EOF
{
  "dns": {
    "rules": [],
    "servers": [
      {
        "address": "tls://1.1.1.1",
        "tag": "dns-remote",
        "detour": "ss",
        "strategy": "ipv4_only"
      }
    ]
  },
  "inbounds": [
    {
      "type": "tun",
      "interface_name": "ipv4-tun",
      "inet4_address": "172.19.0.1/28",
      "mtu": 1500,
      "stack": "gvisor",
      "endpoint_independent_nat": true,
      "auto_route": true,
      "strict_route": true,
      "sniff": true
    }
  ],
  "outbounds": [
    {
      "type": "shadowsocks",
      "tag": "ss",
      "method": "chacha20-ietf-poly1305",
      "password": "${SHADOWSOCKS_PASSWORD}",
      "detour": "shadowtls-out",
      "udp_over_tcp": {
        "enabled": true,
        "version": 2
      }
    },
    {
      "type": "shadowtls",
      "tag": "shadowtls-out",
      "server": "${VPS_IP}",
      "server_port": ${PORT},
      "version": 3,
      "password": "${SHADOWTLS_PASSWORD}",
      "tls": {
        "enabled": true,
        "server_name": "${SITE}",
        "utls": {
          "enabled": true,
          "fingerprint": "firefox"
        }
      }
    },
    {
      "tag": "dns-out",
      "type": "dns"
    }
  ],
  "route": {
    "auto_detect_interface": true,
    "final": "ss",
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      }
    ]
  }
}
EOF
      break;;
    update_config)
      echo "Enter your VPS IP and press enter"
      read -r -e VPS_IP
      echo "Enter domain and press enter"
      read -r -e SITE
      echo "Enter port number 1-65535 Or type random for random port then press enter"
      read -r -e PORT
      if (( "$PORT" < 1 || "$PORT" > 65535)); then
        if [ "$PORT" != "random" ]
        then
          echo "Invalid port number"
          exit
        else
          PORT=$((1024 + $RANDOM))
        fi
      fi
      SHADOWSOCKS_PASSWORD=$(openssl rand -base64 24)
      SHADOWTLS_PASSWORD=$(openssl rand -base64 24)
      cat << EOF > "${HOME}/sing-box/config.json"
{
	"log": {
		"disabled": true
	},
	"dns": {
		"servers": [
			{
				"address": "tls://8.8.8.8"
			}
		]
	},
	"inbounds": [
		{
			"type": "shadowtls",
			"listen": "::",
			"listen_port": ${PORT},
			"version": 3,
			"users": [
				{
					"name": "sekai",
					"password": "${SHADOWTLS_PASSWORD}"
				}
			],
			"handshake": {
				"server": "${SITE}",
				"server_port": 443
			},
			"detour": "shadowsocks-in"
		},
		{
			"type": "shadowsocks",
			"tag": "shadowsocks-in",
			"listen": "127.0.0.1",
			"network": "tcp",
			"method": "chacha20-ietf-poly1305",
			"password": "${SHADOWSOCKS_PASSWORD}"
		}
	],
	"outbounds": [
		{
			"type": "direct"
		},
		{
			"type": "dns",
			"tag": "dns-out"
		}
	],
	"route": {
		"rules": [
			{
				"protocol": "dns",
				"outbound": "dns-out"
			}
		]
	}
}
EOF
      systemctl restart sing-box.service
			echo "Updated!"
			echo "Copy this content for client config.json file"
      cat << EOF
{
  "dns": {
    "rules": [],
    "servers": [
      {
        "address": "tls://1.1.1.1",
        "tag": "dns-remote",
        "detour": "ss",
        "strategy": "ipv4_only"
      }
    ]
  },
  "inbounds": [
    {
      "type": "tun",
      "interface_name": "ipv4-tun",
      "inet4_address": "172.19.0.1/28",
      "mtu": 1500,
      "stack": "gvisor",
      "endpoint_independent_nat": true,
      "auto_route": true,
      "strict_route": true,
      "sniff": true
    }
  ],
  "outbounds": [
    {
      "type": "shadowsocks",
      "tag": "ss",
      "method": "chacha20-ietf-poly1305",
      "password": "${SHADOWSOCKS_PASSWORD}",
      "detour": "shadowtls-out",
      "udp_over_tcp": {
        "enabled": true,
        "version": 2
      }
    },
    {
      "type": "shadowtls",
      "tag": "shadowtls-out",
      "server": "${VPS_IP}",
      "server_port": ${PORT},
      "version": 3,
      "password": "${SHADOWTLS_PASSWORD}",
      "tls": {
        "enabled": true,
        "server_name": "${SITE}",
        "utls": {
          "enabled": true,
          "fingerprint": "firefox"
        }
      }
    },
    {
      "tag": "dns-out",
      "type": "dns"
    }
  ],
  "route": {
    "auto_detect_interface": true,
    "final": "ss",
    "rules": [
      {
        "protocol": "dns",
        "outbound": "dns-out"
      }
    ]
  }
}
EOF
      break;;
    uninstall)
      systemctl disable sing-box.service
      systemctl stop sing-box.service
      rm "/etc/systemd/system/sing-box.service"
      systemctl daemon-reload
      rm -rf "${HOME}/sing-box"
      echo "Uninstalled!" 
      break;;
    quit)
      break;;
    *)
      echo "Invalid option"
      break;;
  esac
done
