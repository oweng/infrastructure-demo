#! /bin/bash
sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable nginx
sudo systemctl daemon-reload
sudo systemctl start nginx
echo "<h1>Deployed via Terraform</h1>" | sudo tee /usr/share/nginx/html/index.html
echo "<h1>HealthCheck</h1>" | sudo tee /usr/share/nginx/html/healthcheck.html