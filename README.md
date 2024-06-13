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

    ./provision_and_deploy.sh

This script will execute the necessary Terraform and Ansible commands to set up the environment,
deploy Kubernetes, Spiderpool, and the applications.

#### Additional manual configuration
It's possible to add new worker in the `variables.tf` file.
Ensure that `SpiderIPPool.yaml` file correctly defines new network configurations and IP pools.

#### Verify deployment
Access the Kubernetes cluster via kubectl and verify node and pod status.
Check if nodes were correctly initalized, pods were created and spiderpool had correctly assigned IPs to them from the previously defined pools.

    $ export KUBECONFIG="./kubeconfig"

    $ kubectl get nodes
    NAME      STATUS   ROLES           AGE   VERSION
    master    Ready    control-plane   3m    v1.30.2
    worker1   Ready    <none>          1m    v1.30.2
    worker2   Ready    <none>          1m    v1.30.2
    worker3   Ready    <none>          1m    v1.30.2
    worker4   Ready    <none>          1m    v1.30.2
    
    $ kubectl get spidermultusconfigs.spiderpool.spidernet.io -n kube-system
    NAME          AGE
    ipvlan-eth0   22m
    ipvlan-eth1   22m
    
    $ kubectl get spiderippools
    NAME          VERSION   SUBNET           ALLOCATED-IP-COUNT   TOTAL-IP-COUNT
    172-31-64-0   4         172.31.64.0/20   0                    16
    172-31-96-0   4         172.31.96.0/20   0                    16

    $ kubectl get pods -owide
    NAME                       READY   STATUS    AGE   IP            NODE
    busybox-5dc5cb4bf6-6kv5d   1/1     Running   24m   172.31.65.3   worker1
    busybox-5dc5cb4bf6-9hxxb   1/1     Running   24m   172.31.66.2   worker2
    busybox-5dc5cb4bf6-9jsts   1/1     Running   24m   172.31.68.1   worker4
    busybox-5dc5cb4bf6-9ml79   1/1     Running   24m   172.31.67.4   worker3

    $ kubectl exec -it busybox-5dc5cb4bf6-6kv5d -- ip -4 addr show scope global
    2: eth0@eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue 
        inet 172.31.65.3/20 brd 172.31.79.255 scope global eth0
           valid_lft forever preferred_lft forever
    4: net1@veth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc noqueue 
        inet 172.31.97.3/20 brd 172.31.111.255 scope global net1
           valid_lft forever preferred_lft forever
