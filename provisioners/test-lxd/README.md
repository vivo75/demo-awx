# creation of demo containers

This directory contain script to create the containers we will use for the demos


## lxd

the LXD module require an inventory which set the connection to the container to LXD.

WARN: if the variable `ansible_connection: lxd` is missing commands will be executed on localhost!

create containers with the following command:

`ansible-playbook -v -i lxd-inventory.yml lxd-containers.yml`


