# Installing k8s (using kubeadm) on OpenStack

### Assumptions

- `openstack` is already installed from where you will run these scripts
- `kubectl`  is already installed 
- `openstack` CLI has been run and can access the OpenStack server

### Steps

- Decide how many K8s nodes you need. Update `setup-node.sh` file. Search for `##CHANGEME` text for locations where changes are required
- `./setup-control-plane.sh` The script will finish by asking you to run a remote SSH command on the Kubernetes Control Plane Droplet to track the progress of `cloud-init` script. Make sure that the `cloud-init` script execution is complete before moving to the next step
- `./setup-node.sh` The script will finish by asking you to run a remote SSH commands on the Kubernetes Node Droplets to track the progress of `cloud-init` script. Make sure that the `cloud-init` script execution is complete before moving to the next step.
- `./setup-finale.sh` Final step that checks the setup and installs Kubernetes Dashboard (and related user credentials)

When you are happy with your setup, run this script to tear things down:

- `./teardown.sh`


