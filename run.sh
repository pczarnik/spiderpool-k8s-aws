#!/usr/bin/env bash

set -eu
set -o pipefail

cd terraform
terraform apply --auto-approve
cd ..

cd ansible
sleep 10
ansible-playbook -i inventory/hosts.cfg predeploy.yml
ansible-playbook -i inventory/hosts.cfg deploy_k8s.yml
ansible-playbook -i inventory/hosts.cfg deploy_spiderpool.yml
cd ..
