#!/bin/bash

# Initialize variables
VM_PREFIX="${1:-play1}"
REGION="${2:-rtp}"
VM_NAME="${VM_PREFIX}-code"
# VM_NAME="${VM_PREFIX}-code-lite"

echo "Running against Region \"${REGION}\" and using the prefix \"${VM_PREFIX}\"..."
echo "VM \"${VM_NAME}\" will be deleted..."
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


# Delete VM
echo "Deleting VM ${VM_NAME}..."
openstack server delete ${VM_NAME} --wait

# Listing the status of OpenStack VMs
echo
echo "Displaying the list of servers in OpenStack Project ${OS_PROJECT_NAME}..."
openstack server list





