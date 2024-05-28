#!/usr/bin/env bash

set -eu
set -o pipefail

cd terraform
terraform apply
cd ..

cd ansible
ansible-playbook -i inventory/hosts.cfg deploy.yml
cd ..
