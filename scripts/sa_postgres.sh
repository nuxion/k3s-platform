#!/bin/bash

source ./scripts/common.sh

BIND_ROLES=( roles/storage.objectAdmin )

sa_account_creator postgres-backup ${BIND_ROLES}
create_sa_account_key postgres-backup 
