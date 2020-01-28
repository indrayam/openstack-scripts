#!/bin/bash

# Initialize variables
REGION="${1:-rtp}"
PROJECT_PREFIX="${2:-play1}"
echo "Running against Region \"${REGION}\" and using the prefix \"${PROJECT_PREFIX}\"..."
read -p "Should we continue? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Quitting!!"
    exit 1
fi
NODE_NAME="node"
NODE_SCRIPT_NAME="${NODE_NAME}.sh"
NODE_TAG_NAME="${PROJECT_PREFIX}-k8s-${NODE_NAME}"

if [ ! -f config/${REGION}.sh ]; then
    # Oops, something went wrong
    echo "The value provided for REGION (${REGION}) is invalid!"
    exit 25
fi
source config/${REGION}.sh
FLAVOR_NAME="4vCPUx8GB"

# Kubernetes Nodes Setup
echo "Alright, time to create VM named ${NODE_TAG_NAME}-1..."
openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
    --security-group default --key-name "$SSH_KEY" \
    --user-data ./${NODE_SCRIPT_NAME} --wait ${NODE_TAG_NAME}-1

echo "Alright, time to create VM named ${NODE_TAG_NAME}-2..."
openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
    --security-group default --key-name "$SSH_KEY" \
    --user-data ./${NODE_SCRIPT_NAME} --wait ${NODE_TAG_NAME}-2

echo "Alright, time to create VM named ${NODE_TAG_NAME}-3..."
openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
    --security-group default --key-name "$SSH_KEY" \
    --user-data ./${NODE_SCRIPT_NAME} --wait ${NODE_TAG_NAME}-3

echo "Alright, time to create VM named ${NODE_TAG_NAME}-4..."
openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
    --security-group default --key-name "$SSH_KEY" \
    --user-data ./${NODE_SCRIPT_NAME} --wait ${NODE_TAG_NAME}-4

echo "Alright, time to create VM named ${NODE_TAG_NAME}-5..."
openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
    --security-group default --key-name "$SSH_KEY" \
    --user-data ./${NODE_SCRIPT_NAME} --wait ${NODE_TAG_NAME}-5

echo "Alright, time to create VM named ${NODE_TAG_NAME}-6..."
openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
    --security-group default --key-name "$SSH_KEY" \
    --user-data ./${NODE_SCRIPT_NAME} --wait ${NODE_TAG_NAME}-6

echo "Alright, time to create VM named ${NODE_TAG_NAME}-7..."
openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
    --security-group default --key-name "$SSH_KEY" \
    --user-data ./${NODE_SCRIPT_NAME} --wait ${NODE_TAG_NAME}-7

echo "Alright, time to create VM named ${NODE_TAG_NAME}-8..."
openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
    --security-group default --key-name "$SSH_KEY" \
    --user-data ./${NODE_SCRIPT_NAME} --wait ${NODE_TAG_NAME}-8

echo "Alright, time to create VM named ${NODE_TAG_NAME}-9..."
openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
    --security-group default --key-name "$SSH_KEY" \
    --user-data ./${NODE_SCRIPT_NAME} --wait ${NODE_TAG_NAME}-9

# Retrieve IP address of Nodes
NODE1_IP=$(openstack server show ${NODE_TAG_NAME}-1 -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
echo "Here's the IP of ${NODE_TAG_NAME}-1: ${NODE1_IP}.."
NODE2_IP=$(openstack server show ${NODE_TAG_NAME}-2 -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
echo "Here's the IP of ${NODE_TAG_NAME}-2: ${NODE2_IP}.."
NODE3_IP=$(openstack server show ${NODE_TAG_NAME}-3 -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
echo "Here's the IP of ${NODE_TAG_NAME}-3: ${NODE3_IP}.."
NODE4_IP=$(openstack server show ${NODE_TAG_NAME}-4 -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
echo "Here's the IP of ${NODE_TAG_NAME}-4: ${NODE4_IP}.."
NODE5_IP=$(openstack server show ${NODE_TAG_NAME}-5 -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
echo "Here's the IP of ${NODE_TAG_NAME}-5: ${NODE5_IP}.."
NODE6_IP=$(openstack server show ${NODE_TAG_NAME}-6 -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
echo "Here's the IP of ${NODE_TAG_NAME}-6 Droplet: ${NODE6_IP}.."
NODE7_IP=$(openstack server show ${NODE_TAG_NAME}-7 -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
echo "Here's the IP of ${NODE_TAG_NAME}-7 Droplet: ${NODE7_IP}.."
NODE8_IP=$(openstack server show ${NODE_TAG_NAME}-8 -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
echo "Here's the IP of ${NODE_TAG_NAME}-8 Droplet: ${NODE8_IP}.."
NODE9_IP=$(openstack server show ${NODE_TAG_NAME}-9 -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
echo "Here's the IP of ${NODE_TAG_NAME}-9 Droplet: ${NODE9_IP}.."

# Finish off
echo
echo "The gerbils are busy building the Kubernetes Nodes on OpenStack..."
echo "Open two terminals and run the following commands to track their progress.."
echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${NODE1_IP} tail -f /var/log/cloud-init-output.log"
echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${NODE2_IP} tail -f /var/log/cloud-init-output.log"
echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${NODE3_IP} tail -f /var/log/cloud-init-output.log"
echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${NODE4_IP} tail -f /var/log/cloud-init-output.log"
echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${NODE5_IP} tail -f /var/log/cloud-init-output.log"
echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${NODE6_IP} tail -f /var/log/cloud-init-output.log"
echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${NODE7_IP} tail -f /var/log/cloud-init-output.log"
echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${NODE8_IP} tail -f /var/log/cloud-init-output.log"
echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${NODE9_IP} tail -f /var/log/cloud-init-output.log"
echo "Enjoy!"


