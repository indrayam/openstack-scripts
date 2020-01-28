# Setup OpenStack Cluster Details (RTP Cluster)
NETWORK_ID="net-id=aebcebae-06a3-4796-8713-4375b03ae0fb"
SSH_KEY="anand on macbook"
FLAVOR_NAME="2vCPUx4GB"
IMAGE_NAME="CoDE-xenial-server-cloudimg-amd64-disk1"

export OS_AUTH_URL="https://cloud-rtp-1.cisco.com:5000/v3"
export OS_IDENTITY_API_VERSION=3
export OS_PROJECT_NAME="${4:-CICD-POC}"
export OS_PROJECT_DOMAIN_NAME="cisco"
export OS_USERNAME="anasharm"
export OS_USER_DOMAIN_NAME="cisco"
