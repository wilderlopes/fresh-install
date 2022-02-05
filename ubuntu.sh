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
	cmake \
    linux-headers-$(uname -r)

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

# Install Nvidia toolkit (CUDA) ---------------------------------------------------------
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.6.0/local_installers/cuda-repo-ubuntu2004-11-6-local_11.6.0-510.39.01-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-6-local_11.6.0-510.39.01-1_amd64.deb
sudo apt-key add /var/cuda-repo-ubuntu2004-11-6-local/7fa2af80.pub
sudo apt-get update
sudo apt-get -y install cuda

