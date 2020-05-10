#!/bin/bash

# How many Kubernetes Nodes do you plan to spin up?
export K8S_NODES="5" ##CHANGEME depending upon how many nodes necessary

# Are we setting this up behind a Bastion Host?
# Run "o server list" to get BASTION_HOST
# Run "o floating ip list" to select K8S_CTLPLANE_IP
export BASTION_HOST="173.37.28.222" ##CHANGEME depending upon whether this is for a closed VPC or open VPC
export K8S_CTLPLANE_IP="173.37.28.223" ##CHANGEME depending upon whether this is for a closed VPC or open VPC

# Generate TOKEN
function generate_token() {
    TOKEN1=`python -c "import random; print ''.join(random.choice('0123456789abcdefghijklmnopqrstuvwxyz') for i in range(6))"`
    TOKEN2=`python -c "import random; print ''.join(random.choice('0123456789abcdefghijklmnopqrstuvwxyz') for i in range(16))"`
    TOKEN="${TOKEN1}.${TOKEN2}"
}

# Suffixes for the AZ in our Data Center
function az_suffixes() {
    if [ "${K8S_NODES}" == "3" ]; then
        AZ_SUFFIXES=("a" "b" "c")
    elif [ "${K8S_NODES}" == "5" ]; then
        AZ_SUFFIXES=("a" "b" "c" "a" "b")
    elif [ "${K8S_NODES}" == "7" ]; then
        AZ_SUFFIXES=("a" "b" "c" "a" "b" "c" "a")
    else 
        echo "Using default number of K8s nodes of 3.."
        AZ_SUFFIXES=("a" "b" "c")
    fi
}
az_suffixes

# How many Nodes?
function num_of_nodes() { 
    if [ "${K8S_NODES}" == "3" ]; then
        NUM_OF_NODES=`python -c 'for i in range(1, 4): print(i)'`
    elif [ "${K8S_NODES}" == "5" ]; then
        NUM_OF_NODES=`python -c 'for i in range(1, 6): print(i)'`
    elif [ "${K8S_NODES}" == "7" ]; then
        NUM_OF_NODES=`python -c 'for i in range(1, 8): print(i)'`
    else 
        echo "Using default number of K8s nodes of 3.."
        NUM_OF_NODES=`python -c 'for i in range(1, 4): print(i)'`
    fi
}
num_of_nodes

