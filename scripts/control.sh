#!/bin/bash

export REDIS_PASSWORD=`echo -n ${REDIS_PASSWORD_PLAIN} | base64`

export PGPASS=`echo -n ${PGPASS_PLAIN} | base64`
export PGADMIN_USER=`echo -n ${PGADMIN_USER_PLAIN} | base64`
export PGADMIN_PASS=`echo -n $PGADMIN_PASS_PLAIN | base64`

source ./scripts/common.sh
CMD="${1:-apply}"
PLATFORM="${2:-local}"
NS="services"


general_apply(){
    apply redis ${PLATFORM} ${NS}
    # apply postgres ${PLATFORM} services
    apply custom-postgres ${PLATFORM} ${NS}
    apply pgadmin ${PLATFORM} ${NS}
}

general_delete(){
    delete redis ${PLATFORM} ${NS}
    # apply postgres ${PLATFORM} services
    delete custom-postgres ${PLATFORM} ${NS}
    # delete pgadmin ${PLATFORM} services
}

case $CMD in
    apply)
        # kubectl apply -f manifests/storage/storage.${PLATFORM}.yaml
        kubectl apply -f manifests/${NS}/ns.yaml
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


