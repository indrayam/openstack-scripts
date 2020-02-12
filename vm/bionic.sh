#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Basic Setup
USER_ID="${USER_ID:-ubuntu}"
USER_HOME="/home/${USER_ID}"

# Update /etc/hosts with the proper entry
HOST=$(hostname)
export VM_IP=$(hostname -I | awk '{print $1}')
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
# Step 1: Install oh-my-zsh
cd ~/src
sudo /usr/bin/chsh -s /usr/bin/zsh ubuntu
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
sh install.sh --unattended
rm install.sh*

# Step 2: Setup SSH keys
cd ~/src
curl -L https://storage.googleapis.com/seaz/bionic.tar.gz.enc -H 'Accept: application/octet-stream' --output bionic.tar.gz.enc
openssl enc -aes-256-cbc -md sha512 -pbkdf2 -iter 100000 -salt -d -in bionic.tar.gz.enc -out bionic.tar.gz
tar -xvzf bionic.tar.gz
mkdir -p ~/.kube
mv dotfiles/kube/* ~/.kube/
mv dotfiles/ssh/* ~/.ssh/
chmod 700 ~/.ssh/
ssh -o "StrictHostKeyChecking no" -T git@github.com

# Step 3: Pull down my .dotfiles repo and setup vim, kube-ps1
cd ~
git clone git@github.com:indrayam/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
~/.dotfiles/setup-symlinks-linux.sh
rm -rf ~/.vim/bundle/Vundle.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim -c 'PluginInstall' -c 'qall'
git clone git@github.com:jonmosco/kube-ps1.git ~/.kube-ps1
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
mkdir -p ~/.oh-my-zsh/completions
chmod -R 755 ~/.oh-my-zsh/completions
ln -s /opt/kubectx/completion/kubectx.zsh ~/.oh-my-zsh/completions/_kubectx.zsh
ln -s /opt/kubectx/completion/kubens.zsh ~/.oh-my-zsh/completions/_kubens.zsh

# Step 4: Final touches...
mkdir -p /home/ubuntu/workspace
sudo usermod -aG docker $USER_ID
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
  https://raw.githubusercontent.com/so-fancy/diff-so-fancy/master/third_party/build_fatpack/diff-so-fancy
chown ${USER_ID}.${USER_ID} ${USER_HOME}/src/*

## Install diff-so-fancy
cd ${USER_HOME}/src
chmod +x diff-so-fancy
mv diff-so-fancy /usr/local/bin
diff-so-fancy -v

# Container Tools
apt-get install -y containerd.io=1.2.10-3 docker-ce=5:19.03.4~3-0~ubuntu-$(lsb_release -cs) docker-ce-cli=5:19.03.4~3-0~ubuntu-$(lsb_release -cs) kubectl

# Setup Docker daemon
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker
systemctl daemon-reload
systemctl restart docker

# Final update and upgrade
echo "N" > /tmp/silent-configure
apt-get -y update
apt-get -y upgrade < /tmp/silent-configure
apt-get -y install unattended-upgrades apt-listchanges bsd-mailx
