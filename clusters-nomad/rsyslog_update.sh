#!/bin/bash

while true; do
    read -p "Are you sure ?.. [y/n] " yn
    case $yn in
        [Yy]* )

            ansible-playbook plays/apply/apply_consul.yml --tags update-rsyslog
            ansible-playbook plays/apply/apply_vault.yml --tags update-rsyslog
            ansible-playbook plays/apply/apply_entry.yml --tags update-rsyslog
            ansible-playbook plays/apply/apply_nomad_masters.yml --tags update-rsyslog
            ansible-playbook plays/apply/apply_nomad_workers.yml --tags update-rsyslog

            break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
