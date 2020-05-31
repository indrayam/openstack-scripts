#!/bin/bash

# Initialize variables
VM_PREFIX="${1:-play1}"
REGION="${2:-rtp}"
VM_NAME="${VM_PREFIX}-code"
VM_SCRIPT="bionic.sh"

echo "Running against Region \"${REGION}\" and using the prefix \"${VM_PREFIX}\"..."
echo "VM \"${VM_NAME}\" will be created..."
read -p "Should we continue? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Quitting!!"
    exit 1
fi

if [ ! -f config/${REGION}.sh ]; then
    # Oops, something went wrong
    echo "The value provided for REGION (${REGION}) is invalid!"
    exit 25
fi
source config/${REGION}.sh
export FLAVOR_NAME="4vCPUx8GB"
# export AZ_NAME="cloud-${REGION}-1-a"

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

