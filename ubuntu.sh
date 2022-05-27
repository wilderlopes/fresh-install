#!/bin/bash
#
# Script to setup Ubuntu after a fresh install. Tested with Ubuntu 20.04.
#
# wilder@ogarantia.com
# Feb 2022
#
# The steps below assume the ssh are already present in the new system.

echo ">>> FRESH INSTALL OF UBUNTU 20.04"

#  Update and install dependencies ------------------------------------------------------
echo ">>> apt update and install packages"
sudo apt-get update && sudo apt-get install -y \
	vim \
	git \
	curl \
	build-essential \
	cmake \
	ca-certificates \
        gnupg \
        lsb-release \
        linux-headers-$(uname -r) \
        python3-dev \
        python3-pip
	
# Clone linux scripts from Github -------------------------------------------------------
echo ">>> Clone repos from GitHub"
cd /home/wilder && \
    git clone git@github.com:wilderlopes/my-scripts.git && \
    git clone git@github.com:wilderlopes/my-dotfiles.git

echo 'export PATH="$HOME/my-scripts":$PATH' >> /home/wilder/.bashrc
echo 'export PATH="$HOME/.local/bin":$PATH' >> /home/wilder/.bashrc
source /home/wilder/.bashrc

# Copy dotfiles to home folder ----------------------------------------------------------
echo ">>> Set up dotfiles"
cp my-dotfiles/.vimrc .
cp my-dotfiles/.bash_aliases .

# Install Docker engine and Nvidia Docker -----------------------------------------------
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group to enable using docker without sudo (after logout and login)
newgrp docker
sudo usermod -aG docker $USER

echo ">>> Run Docker hello-world"
sudo docker run hello-world

# Install Nvidia toolkit (CUDA) ---------------------------------------------------------
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/11.6.0/local_installers/cuda-repo-ubuntu2004-11-6-local_11.6.0-510.39.01-1_amd64.deb
sudo dpkg -i cuda-repo-ubuntu2004-11-6-local_11.6.0-510.39.01-1_amd64.deb
sudo apt-key add /var/cuda-repo-ubuntu2004-11-6-local/7fa2af80.pub
sudo apt-get update
sudo apt-get -y install cuda

# Install ML utilities ------------------------------------------------------------------
echo ">>> Install ML utilities"
pip install numpy tensorflow tensorboard
