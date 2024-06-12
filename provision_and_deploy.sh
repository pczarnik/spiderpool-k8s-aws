#!/usr/bin/env bash

set -eu
set -o pipefail

echo "Generating ssh-key for cluster"
echo -e 'y\n' | ssh-keygen -t ed25519 -f ./id_ed25519 -N '' -q 1> /dev/null

echo "Applying terraform configuration"
cd terraform
terraform init
terraform apply --auto-approve
cd -

echo "Deploying with ansible"
ansible-playbook -i ansible/inventory/hosts.cfg ansible/pre-deploy.yml
ansible-playbook -i ansible/inventory/hosts.cfg ansible/deploy-k8s.yml
ansible-playbook -i ansible/inventory/hosts.cfg ansible/deploy-spiderpool.yml
ansible-playbook -i ansible/inventory/hosts.cfg ansible/deploy-apps.yml

echo "To use kubectl run: 'export KUBECONFIG=\"$(realpath kubeconfig)\"'"
