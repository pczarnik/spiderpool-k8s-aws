# spiderpool-k8s-aws
## Overview

The Spiderpool project aims to manage IP addresses in a Kubernetes cluster using Spiderpool and Multus CNI plugin.
This project utilizes Terraform and Ansible to provision AWS EC2 instances and deploy k8s with spiderpool on them.

![Spiderpool network configuration](https://raw.githubusercontent.com/pczarnik/spiderpool-k8s-aws/main/imgs/spiderpool.jpg)

## Installation
### Prerequisites:

  1.   AWS account with necessary permissions and credentials stored in `~/.aws/credentials`.
  2.   `terraform` (v0.12 or later).
  3.   `ansible` (v2.9 or later).
  4.   `ssh` public key in `~/.ssh/id_ed25519.pub`.
  5.   `helm`.
  6.   `kubectl`.

#### Dependencies:

    ansible-galaxy collection install kubernetes.core
    pip install "Jinja2<3.1"
    pip install kubernetes

### Steps:
#### Clone the repo:

    git clone https://github.com/pczarnik/spiderpool-k8s-aws.git
    cd spiderpool-k8s-aws

#### Run provisioner and deployer script:

    chmod +x run.sh
    ./run.sh

This script will execute the necessary Terraform and Ansible commands to set up the environment,
deploy Kubernetes, Spiderpool, and the applications.

#### Additional manual configuration
It's possible to add new worker in the `variables.tf` file.
Ensure that `SpiderIPPool.yaml` file correctly defines new network configurations and IP pools.

#### Verify deployment
Access the Kubernetes cluster via kubectl and verify node and pod status.
Check if nodes were correctly initalized, pods were created and spiderpool had correctly assigned IPs to them from the previously defined pools.

    kubectl get nodes
    kubectl get pods -A
    kubectl exec -it {{ item }} -- ip -4 addr show scope global

Check that Spiderpool has correctly assigned IPs from the defined pools to the pods.
