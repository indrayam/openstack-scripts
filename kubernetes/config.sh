#!/bin/bash

# Generate TOKEN
function generate_token() {
    # TOKEN=`python2 -c 'import random; print "%0x.%0x" % (random.SystemRandom().getrandbits(3*8), random.SystemRandom().getrandbits(8*8))'`
    TOKEN1=`python2 -c "import random; print ''.join(random.choice('0123456789abcdefghijklmnopqrstuvwxyz') for i in range(6))"`
    TOKEN2=`python2 -c "import random; print ''.join(random.choice('0123456789abcdefghijklmnopqrstuvwxyz') for i in range(16))"`
    TOKEN="${TOKEN1}.${TOKEN2}"
}

# Suffixes for the AZ in our Data Center
function az_suffixes() { 
    AZ_SUFFIXES=("a" "b" "c") ##CHANGEME depending upon how many nodes necessary
}
az_suffixes

# How many Nodes?
function num_of_nodes() { 
    NUM_OF_NODES=`python2 -c 'for i in range(1, 4): print(i)'` ##CHANGEME depending upon how many nodes necessary
}
num_of_nodes
