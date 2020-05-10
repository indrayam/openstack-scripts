#!/bin/bash

CTRLPLANE_IP=111.111.111.111

# Sourcing the utility functions and variables
if [ ! -f config.sh ]; then
    # Oops, something went wrong
    echo "What happened to the configuration file! config.sh NOT FOUND :-("
    exit 25
fi
source config.sh

PROJECT_PREFIX="${1:-play1}"
echo "Running using the prefix \"${PROJECT_PREFIX}\"..."
read -p "Should we continue? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Quitting!!"
    exit 1
fi
NODE_NAME="node"
NODE_TAG_NAME="${PROJECT_PREFIX}-k8s-${NODE_NAME}"

echo "Using Control Plane IP value of \"${CTRLPLANE_IP}\"..."
read -p "Should we continue? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Quitting!!"
    exit 1
fi

# Pull down Kubernetes Cluster Configuration
echo "Pulling down the Kubernetes Cluster Configuration..."
if [ -z ${BASTION_HOST+x} ]; then
    echo "BASTION_HOST is unset"
    scp -o StrictHostKeyChecking=no ubuntu@${CTRLPLANE_IP}:/home/ubuntu/.kube/config admin.conf
else
    echo "BASTION_HOST is set to ${BASTION_HOST}"
    scp -o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p ubuntu@${BASTION_HOST}" ubuntu@${CTRLPLANE_IP}:/home/ubuntu/.kube/config admin.conf
    sed -i.bak "s/^    server:.*/    server: https:\/\/${K8S_CTLPLANE_IP}:6443/" ./admin.conf
fi

# Confirm the creation of Nodes
echo "Time to connect to the Cluster..."
CURR_DIR=`pwd`
export KUBECONFIG=$CURR_DIR/admin.conf
kubectl get nodes

# Install Kubernetes Dashboard
echo "Installing Kubernetes Dashboard..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
echo "Creating an admin-user..."
kubectl apply -f ./k8s-dashboard-user/admin-user.yml
echo "Creating a Cluster Role Binding Role..."
kubectl apply -f ./k8s-dashboard-user/admin-user-role.yml

# Update Kubernetes Kubeconfig to all Nodes
for i in ${NUM_OF_NODES}; do 
    NODE_IP=$(openstack server show ${NODE_TAG_NAME}-${i} -f json | jq '.addresses' | sed s/\"//g | cut -d'=' -f2)
    echo "Uploading admin.conf to ${NODE_TAG_NAME}-${i} whose IP is ${NODE_IP}.."
    if [ -z ${BASTION_HOST+x} ]; then
        echo "BASTION_HOST is unset"
        scp -o StrictHostKeyChecking=no admin.conf ubuntu@${NODE_IP}:/home/ubuntu/.kube/config
    else
        echo "BASTION_HOST is set to ${BASTION_HOST}"
        scp -o StrictHostKeyChecking=no -o ProxyCommand="ssh -W %h:%p ubuntu@${BASTION_HOST}" admin.conf ubuntu@${NODE_IP}:/home/ubuntu/.kube/config
    fi
done

# Final message
echo
echo "List the Bearer token to be used for Kubernetes Dashboard login..."
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')
echo
echo
echo "To checkout the dashboard, run.."
echo "kubectl --kubeconfig admin.conf proxy --port 8001"
echo "Once running, open the browser and enter the following URL:"
echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
echo "Enjoy!"
