#!/bin/bash
#
# Script to setup Ubuntu after a fresh install. Tested with Ubuntu 20.04.
#
# wilder@ogarantia.com
# Feb 2022
#
# The steps below assume the ssh are already present in the new system.

#  Update and install dependencies ------------------------------------------------------
sudo apt-get update && sudo apt-get install -y \
	vim \
	git \
	curl \
	build-essential \
	cmake

# Clone linux scripts from Github -------------------------------------------------------
cd /home/wilder && \
    git clone git@github.com:wilderlopes/my-scripts.git && \
    git clone git@github.com:wilderlopes/my-dotfiles.git

echo 'export PATH="/home/wilder/my-scripts":$PATH' >> /home/wilder/.bashrc

# Copy dotfiles to home folder ----------------------------------------------------------
cp my-dotfiles/.vimrc .
cp my-dotfiles/.bash_aliases .

# Install Docker engine and Nvidia Docker -----------------------------------------------
curl https://get.docker.com | sh && sudo systemctl --now enable docker

distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker

# Add user to docker group to enable using docker without sudo --------------------------
sudo usermod -aG docker $USER && newgrp docker

echo ">>> Run Docker hello-world"
docker run hello-world
