#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Replace this with the token 
TOKEN=xxxxxx.yyyyyy

# Basic Setup
USER_ID="${USER_ID:-ubuntu}"
USER_HOME="/home/${USER_ID}"

# Update /etc/hosts with the proper entry
HOST=$(hostname)
export CTRLPLANE_IP=$(hostname -I | awk '{print $1}')
sed -i "1s/^/${VM_IP} ${HOST}\n/" /etc/hosts

## Pre-requisite steps
add-apt-repository -y ppa:jonathonf/vim
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update

# Install Essentials
apt-get install -y apt-transport-https ca-certificates software-properties-common nfs-common vim zsh curl wget tar zip socat jq silversearcher-ag
chown -R ${USER_ID}.${USER_ID} /usr/local/src
ln -s /usr/local/src ${USER_HOME}/src
chown -h ${USER_ID}.${USER_ID} ${USER_HOME}/src

# Create a shell script to finish personalizing my non-root account setup
cat > ${USER_HOME}/complete-os-setup.sh <<EOF
cd ~/src
sudo chown -R ubuntu.ubuntu ~/.kube

# Step 1: Install oh-my-zsh
cd ~/src
sudo /usr/bin/chsh -s /usr/bin/zsh ${USER_ID}
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
sh install.sh --unattended
rm install.sh*

# Step 2: Setup SSH keys and pull down my .dotfiles repo
cd ~/src
curl -L https://storage.googleapis.com/seaz/bionic.tar.gz.enc -H 'Accept: application/octet-stream' --output bionic.tar.gz.enc
openssl aes-256-cbc -d -in bionic.tar.gz.enc -out bionic.tar.gz
tar -xvzf bionic.tar.gz
mv dotfiles/ssh/* ~/.ssh/
mkdir -p ~/.kube
mv dotfiles/kube/* ~/.kube/
chmod 700 ~/.ssh/
ssh -o "StrictHostKeyChecking no" -T git@github.com

# Step 3: Setup Vim
cd ~
git clone git@github.com:indrayam/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
~/.dotfiles/setup-symlinks-linux.sh
rm -rf ~/.vim/bundle/Vundle.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim -c 'PluginInstall' -c 'qall'
git clone git@github.com:jonmosco/kube-ps1.git ~/.kube-ps1

# Step 4: Final touches...
mkdir -p ${USER_HOME}/workspace
echo "You're done! Remove this file, exit and log back in to enjoy your new VM"
EOF
chmod +x ${USER_HOME}/complete-os-setup.sh
chown ${USER_ID}.${USER_ID} ${USER_HOME}/complete-os-setup.sh

# Stop Firewall Service
systemctl stop firewalld
systemctl disable firewalld

## Install tools
cd ${USER_HOME}/src

## Download binaries and/or source
wget -q --https-only --timestamping \
  https://github.com/ahmetb/kubectx/archive/v0.7.1.tar.gz \
  https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
chown ${USER_ID}.${USER_ID} ${USER_HOME}/src/*

## Install kubectx, kubens
tar -xvzf v0.7.1.tar.gz
chown -R ${USER_ID}.${USER_ID} kubectx-0.7.1/
mv kubectx-0.7.1/kubectx kubectx-0.7.1/kubens /usr/local/bin

## Install diff-so-fancy
cd ${USER_HOME}/src
chmod +x diff-so-fancy
mv diff-so-fancy /usr/local/bin
diff-so-fancy -v

# Container Tools
apt-get install -y --allow-unauthenticated docker-ce=$(apt-cache madison docker-ce | grep 19.03 | head -1 | awk '{print $3}')
apt-get install -y kubectl

# Upgrade the OS
apt -y update
apt -y upgrade
apt -y install unattended-upgrades apt-listchanges bsd-mailx
