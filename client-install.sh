#!/bin/bash

apt-get update
apt-get install -y unzip

wget https://releases.hashicorp.com/nomad/0.3.2/nomad_0.3.2_linux_amd64.zip
unzip nomad_0.3.2_linux_amd64.zip
mv nomad /usr/local/bin/

mkdir -p /var/lib/nomad
mkdir -p /etc/nomad

rm nomad_0.3.2_linux_amd64.zip

cat > client.hcl <<EOF
bind_addr = "0.0.0.0"
data_dir  = "/var/lib/nomad"
log_level = "DEBUG"

client {
    enabled = true
    servers = [
      "ns-1", "ns-2", "ns-3"
    ]
    options {
        "driver.raw_exec.enable" = "1"
    }
}
EOF
mv client.hcl /etc/nomad/client.hcl

cat > nomad.service <<'EOF'
[Unit]
Description=Nomad
Documentation=https://nomadproject.io/docs/

[Service]
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad
ExecReload=/bin/kill -HUP $MAINPID
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
mv nomad.service /etc/systemd/system/nomad.service

systemctl enable nomad
systemctl start nomad
