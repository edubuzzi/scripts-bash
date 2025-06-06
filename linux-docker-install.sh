sudo apt update -y && sudo apt upgrade -y
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg2
curl -fsSL https://get.docker.com | sudo sh
sudo systemctl enable docker

sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
