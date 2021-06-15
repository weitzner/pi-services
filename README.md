# pi-services
The things I run on my raspberry pi
1. [pi-hole](https://pi-hole.net)
2. [homebridge](https://homebridge.io)

To use these files, make sure you have docker and docker-compose installed on your raspberry pi

```bash
sudo apt-get update && sudo apt-get upgrade
curl -sSL https://get.docker.com | sh

# add current (i.e. non-root) user to docker group
sudo usermod -aG docker ${USER}

# optionally check groups with the following command
# groups ${USER}

# install tools needed to install docker-compose
sudo apt-get install libffi-dev libssl-dev
sudo apt install python3-dev
sudo apt-get install -y python3 python3-pip

# install docker-compose and enable service
sudo pip3 install docker-compose
sudo systemctl enable docker

# test with hello world container
docker run hello-world
```
