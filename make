#! /usr/bin/bash

pushd  ${0%/*}
  ansible-inventory -i inventories/ --list --yaml | tee inventory.yaml
popd
