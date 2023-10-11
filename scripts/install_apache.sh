#!/bin/bash
apt update -y
apt install apache2 -y
systemctl start apache2
systemctl enable apache2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt install unzip
unzip awscliv2.zip
./aws/install