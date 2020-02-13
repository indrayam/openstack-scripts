#!/bin/bash

# How many Nodes?
function az_suffixes() { 
    AZ_SUFFIXES=("a" "b" "c") ##CHANGEME depending upon how many nodes necessary
}
az_suffixes

function num_of_nodes() { 
    NUM_OF_NODES=`python -c 'for i in range(1, 4): print(i)'` ##CHANGEME depending upon how many nodes necessary
}
num_of_nodes
