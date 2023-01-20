#!/bin/bash

export REDIS_PASSWORD=`echo -n ${REDIS_PASSWORD_PLAIN} | base64`

export PGPASS=`echo -n ${PGPASS_PLAIN} | base64`
export PGADMIN_USER=`echo -n ${PGADMIN_USER_PLAIN} | base64`
export PGADMIN_PASS=`echo -n $PGADMIN_PASS_PLAIN | base64`

source ./scripts/common.sh
CMD="${1:-apply}"
PLATFORM="${2:-local}"


general_apply(){
    apply redis ${PLATFORM} services
    # apply postgres ${PLATFORM} services
    apply custom-postgres ${PLATFORM} services
    # apply pgadmin ${PLATFORM} services
}

case $CMD in
    apply)
        # kubectl apply -f manifests/storage/storage.${PLATFORM}.yaml
        kubectl apply -f manifests/services/ns.yaml
        general_apply
        ;;

    delete)
        general_delete
        ;;
    *)
        echo "Use apply or delete"
        exit 1
        ;;
esac


