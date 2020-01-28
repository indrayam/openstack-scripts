#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Replace this with the token 
TOKEN=xxxxxx.yyyyyy

# Basic Setup
USER_ID="${USER_ID:-ubuntu}"
USER_HOME="/home/${USER_ID}"

## Pre-requisite steps
# Get things setup for Vim and Certbot
add-apt-repository -y ppa:jonathonf/vim
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
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
curl -L https://storage.googleapis.com/us-east-4-anand-files/misc-files/linux-bootstrap.tar.gz.enc -H 'Accept: application/octet-stream' --output linux-bootstrap.tar.gz.enc
openssl aes-256-cbc -d -in linux-bootstrap.tar.gz.enc -out linux-bootstrap.tar.gz
tar -xvzf linux-bootstrap.tar.gz
mv ssh/* ~/.ssh/
mv config ~/.config
mkdir -p ~/.kube
mv kube/* ~/.kube/
chmod 700 ~/.ssh/
rm -rf ssh/ ssh.tar.gz
ssh -o "StrictHostKeyChecking no" -T git@github.com

# Step 3: Setup Vim
cd ~
git clone git@github.com:indrayam/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
~/.dotfiles/setup-symlinks-unix.sh
rm -rf ~/.vim/bundle/Vundle.vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim -c 'PluginInstall' -c 'qall'

# Step 4: Final touches...
mkdir -p ${USER_HOME}/workspace
echo "You're done! Remove this file, exit and log back in to enjoy your new VM"
EOF
chmod +x ${USER_HOME}/complete-os-setup.sh
chown ${USER_ID}.${USER_ID} ${USER_HOME}/complete-os-setup.sh

# Stop Firewall Service
systemctl stop firewalld
systemctl disable firewalld

## Install Cloud Native tools
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

# Kubernetes Control Plane Setup
apt-get install -y --allow-unauthenticated docker-ce=$(apt-cache madison docker-ce | grep 19.03 | head -1 | awk '{print $3}')
apt-get install -y kubelet kubeadm kubectl kubernetes-cni

# Initialize Kubernetes Control Plane using kubeadm
export CTRLPLANE_IP=$(hostname -I | awk '{print $1}')
kubeadm init --pod-network-cidr=192.168.0.0/16  --apiserver-advertise-address $CTRLPLANE_IP --token $TOKEN --apiserver-cert-extra-sans 173.37.68.59

# Copying it under home directory of 'root'
cp /etc/kubernetes/admin.conf $HOME/
chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

# Copying it under home directory of 'anasharm'
mkdir -p ${USER_HOME}/.kube
cp /etc/kubernetes/admin.conf ${USER_HOME}/.kube/config
chown ${USER_ID}.${USER_ID} ${USER_HOME}/.kube/config

# Install Networking Plugin (Calico)
# kubectl apply -f https://docs.projectcalico.org/v3.0/getting-started/kubernetes/installation/hosted/kubeadm/1.7/calico.yaml

# Install Networking Plugin (Weave)
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

# Update /etc/hosts with the proper entry
HOST=$(hostname)
sed -i "1s/^/${CTRLPLANE_IP} ${HOST}\n/" /etc/hosts

