#!/bin/bash

# Sourcing the utility functions and variables
if [ ! -f config.sh ]; then
    # Oops, something went wrong
    echo "What happened to the configuration file! config.sh NOT FOUND :-("
    exit 25
fi
source config.sh

# Initialize variables
PROJECT_PREFIX="${1:-play1}"
REGION="${2:-rtp}"
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
export FLAVOR_NAME="4vCPUx8GB"


# Kubernetes Node(s) Setup
for i in ${NUM_OF_NODES}; do 
    # If you want to generate the selections randomly
    # AZ_SUFFIX_SELECTED=${AZ_SUFFIXES[$RANDOM % ${#AZ_SUFFIXES[@]} ]} 
    # If you want to just loop through a, b and c
    AZ_SUFFIX_SELECTED=${AZ_SUFFIXES[$(($i - 1))]}
    echo "Alright, time to create VM named ${NODE_TAG_NAME}-${i}..."
    export AZ_NAME="cloud-${REGION}-1-${AZ_SUFFIX_SELECTED}"
    openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
        --availability-zone $AZ_NAME \
        --security-group default --key-name "$SSH_KEY" \
        --user-data ./${NODE_SCRIPT_NAME} --wait ${NODE_TAG_NAME}-${i}
done

# Retrieve IP address of Node(s) and publish the SSH command to see the logs
for i in ${NUM_OF_NODES}; do 
    NODE_IP=$(openstack server show ${NODE_TAG_NAME}-${i} -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
    echo "Here's the IP of ${NODE_TAG_NAME}-${i}: ${NODE_IP}.."
    if [ -z ${BASTION_HOST+x} ]; then
        echo "BASTION_HOST is unset"
        echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${NODE_IP} tail -f /var/log/cloud-init-output.log"
    else
        echo "BASTION_HOST is set to ${BASTION_HOST}"
        echo "ssh -o \"StrictHostKeyChecking no\" -o ProxyCommand=\"ssh -W %h:%p ubuntu@${BASTION_HOST}\" -T ubuntu@${NODE_IP} tail -f /var/log/cloud-init-output.log"
    fi
done

# Finish off
echo
echo "The gerbils are busy building the Kubernetes Nodes on OpenStack..."
echo "Open two terminals and run the ssh commands (see above) to track their progress.."
echo "Enjoy!"
