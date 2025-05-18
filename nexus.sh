#!/bin/bash

# Update and install packages
sudo yum update -y
sudo yum install -y wget tar java-17-amazon-corretto

# Create application directories
sudo mkdir -p /app /app/sonatype-work
cd /app

# Download and extract Nexus
sudo wget https://download.sonatype.com/nexus/3/nexus-unix-x86-64-3.78.2-04.tar.gz
sudo tar -xvf nexus-unix-x86-64-3.78.2-04.tar.gz
sudo mv nexus-3.78.2-04 nexus

# Create nexus user
sudo adduser nexus

# Change ownership
sudo chown -R nexus:nexus /app/nexus
sudo chown -R nexus:nexus /app/sonatype-work

# Set the run user
echo 'run_as_user="nexus"' | sudo tee /app/nexus/bin/nexus.rc

# Create systemd service file
sudo tee /etc/systemd/system/nexus.service > /dev/null << EOL
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
User=nexus
Group=nexus
ExecStart=/app/nexus/bin/nexus start
ExecStop=/app/nexus/bin/nexus stop
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOL

# Reload daemon and start nexus
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus
sudo systemctl status nexus
