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


if [ ! -f config/${REGION}.sh ]; then
    # Oops, something went wrong
    echo "The value provided for REGION (${REGION}) is invalid!"
    exit 25
fi
source config/${REGION}.sh


# Delete all VMs
echo "Deleting VM ${CTRLPLANE_TAG_NAME}..."
openstack server delete ${CTRLPLANE_TAG_NAME} --wait
for i in ${NUM_OF_NODES}; do 
    echo "Deleting VM ${NODE_TAG_NAME}-${i}..."
    openstack server delete ${NODE_TAG_NAME}-${i} --wait
done

# Listing the status of OpenStack VMs
echo
echo "Displaying the list of servers in OpenStack Project ${OS_PROJECT_NAME}..."
openstack server list





