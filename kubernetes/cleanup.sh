#!/bin/bash

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
