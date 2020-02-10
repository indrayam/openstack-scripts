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
CTRLPLANE_NAME="control-plane"
CTRLPLANE_SCRIPT_NAME="${CTRLPLANE_NAME}.sh"
CTRLPLANE_TAG_NAME="${PROJECT_PREFIX}-k8s-${CTRLPLANE_NAME}"
NODE_NAME="node"
NODE_SCRIPT_NAME="${NODE_NAME}.sh"
NODE_TAG_NAME="${PROJECT_PREFIX}-k8s-${NODE_NAME}"


if [ ! -f config/${REGION}.sh ]; then
    # Oops, something went wrong
    echo "The value provided for REGION (${REGION}) is invalid!"
    exit 25
fi
source config/${REGION}.sh

# Remove Kubernetes Cluster Configuration file
echo "Removing Kubernetes Cluster Configuration file admin.conf..."
CURR_DIR=`pwd`
rm -f $CURR_DIR/admin.conf

# Cleanup
echo "Reverting ./setup-finale.sh back to its original condition..."
sed -i.bak "s/^CTRLPLANE_IP=.*/CTRLPLANE_IP=111.111.111.111/" ./setup-finale.sh
echo "Reverting ./node.sh back to its original condition..."
sed -i.bak "s/^CTRLPLANE_IP=.*/CTRLPLANE_IP=111.111.111.111/" ./node.sh
sed -i.bak "s/^TOKEN=.*/TOKEN=xxxxxx.yyyyyy/" ./node.sh
echo "Reverting ./control-plane.sh back to its original condition..."
sed -i.bak "s/^TOKEN=.*/TOKEN=xxxxxx.yyyyyy/" ./control-plane.sh
rm *.bak

# Delete all VMs
echo "Deleting VM ${CTRLPLANE_TAG_NAME}..."
openstack server delete ${CTRLPLANE_TAG_NAME} --wait
for i in 1 2 3; do
    echo "Deleting VM ${NODE_TAG_NAME}-${i}..."
    openstack server delete ${NODE_TAG_NAME}-${i} --wait
done

# Listing the status of OpenStack VMs
echo
echo "Displaying the list of servers in OpenStack Project ${OS_PROJECT_NAME}..."
openstack server list





