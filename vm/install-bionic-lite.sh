#!/bin/bash

# Initialize variables
VM_PREFIX="codedemo"
VM_NUMBER="${1:-bionic-lite}"
VM_NAME="${VM_PREFIX}-${VM_NUMBER}"
VM_SCRIPT="bionic.sh"
NETWORK_ID="net-id=aebcebae-06a3-4796-8713-4375b03ae0fb"
SSH_KEY="anand on macbook"
FLAVOR_NAME="2vCPUx4GB"
IMAGE_NAME="UBUNTU-18.04-CORE"
AZ_NAME="cloud-rtp-1-a"

export OS_AUTH_URL="https://cloud-rtp-1.cisco.com:5000/v3"
export OS_IDENTITY_API_VERSION=3
export OS_PROJECT_NAME="${4:-CICD-POC}"
export OS_PROJECT_DOMAIN_NAME="cisco"
export OS_USERNAME="anasharm"
export OS_USER_DOMAIN_NAME="cisco"

# Instantiate VM
echo "Creating VM named ${VM_NAME}..."
sleep 1
openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
    --availability-zone $AZ_NAME \
    --security-group default --key-name "$SSH_KEY" \
    --user-data ./${VM_SCRIPT} --wait ${VM_NAME}

# Retrieve IP address of VM Plane
VM_IP=$(openstack server show ${VM_NAME} -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
echo "Here's the IP of ${VM_NAME}: ${VM_IP}"

# Finish off
echo
echo "The gerbils are busy building the VM on OpenStack..."
echo "Open a terminal and run the following commands to track the progress.."
echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${VM_IP} tail -f /var/log/cloud-init-output.log"
echo "Enjoy!"

