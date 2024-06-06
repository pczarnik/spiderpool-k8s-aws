#!/usr/bin/env bash

set -eu
set -o pipefail

cd terraform
# terraform apply --auto-approve
cd ..

cd ansible
# ansible-playbook -i inventory/hosts.cfg pre-deploy.yml
ansible-playbook -i inventory/hosts.cfg deploy-k8s.yml
ansible-playbook -i inventory/hosts.cfg deploy-spiderpool.yml
ansible-playbook -i inventory/hosts.cfg deploy-apps.yml
cd ..
