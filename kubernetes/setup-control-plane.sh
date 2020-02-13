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
CTRLPLANE_NAME="control-plane"
CTRLPLANE_SCRIPT_NAME="${CTRLPLANE_NAME}.sh"
CTRLPLANE_TAG_NAME="${PROJECT_PREFIX}-k8s-${CTRLPLANE_NAME}"
NODE_SCRIPT_NAME="node.sh"
FINALE_SCRIPT_NAME="setup-finale.sh"

if [ ! -f config/${REGION}.sh ]; then
    # Oops, something went wrong
    echo "The value provided for REGION (${REGION}) is invalid!"
    exit 25
fi
source config/${REGION}.sh
export FLAVOR_NAME="4vCPUx8GB"
export AZ_NAME="cloud-${REGION}-1-a"

# Generate token and insert into the script files
echo "Creating a secure(ish) token for use in Kubernetes Cluster setup..."
generate_token
echo "Token: $TOKEN"
echo "Time to update ./${CTRLPLANE_SCRIPT_NAME} file with ${TOKEN}..."
sed -i.bak "s/^TOKEN=.*/TOKEN=${TOKEN}/" ./${CTRLPLANE_SCRIPT_NAME}
echo "Time to update ./${NODE_SCRIPT_NAME} file with ${TOKEN}..."
sed -i.bak "s/^TOKEN=.*/TOKEN=${TOKEN}/" ./${NODE_SCRIPT_NAME}

# Kubernetes Control Plane Setup Start
echo "Alright, time to create VM named ${CTRLPLANE_TAG_NAME}..."
openstack server create --flavor $FLAVOR_NAME --image $IMAGE_NAME --nic $NETWORK_ID \
    --availability-zone $AZ_NAME \
    --security-group default --key-name "$SSH_KEY" \
    --user-data ./${CTRLPLANE_SCRIPT_NAME} --wait ${CTRLPLANE_TAG_NAME}

# Retrieve IP address of Control Plane
CTRLPLANE_IP=$(openstack server show ${CTRLPLANE_TAG_NAME} -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
echo "Here's the IP of ${CTRLPLANE_TAG_NAME} Droplet: ${CTRLPLANE_IP}"
echo "Time to update ./${NODE_SCRIPT_NAME} file with this IP.."
sed -i.bak "s/^CTRLPLANE_IP=.*/CTRLPLANE_IP=${CTRLPLANE_IP}/" ./${NODE_SCRIPT_NAME}
echo "Time to update ${FINALE_SCRIPT_NAME} file with this IP.."
sed -i.bak "s/^CTRLPLANE_IP=.*/CTRLPLANE_IP=${CTRLPLANE_IP}/" ./${FINALE_SCRIPT_NAME}

# Finish off
echo
echo "The gerbils are busy building the Kubernetes Control Plane Droplet on OpenStack..."
echo "Open a terminal and run the following commands to track the progress.."
echo "ssh -o \"StrictHostKeyChecking no\" -T ubuntu@${CTRLPLANE_IP} tail -f /var/log/cloud-init-output.log"
echo "Enjoy!"

