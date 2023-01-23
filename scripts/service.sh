#!/bin/bash

#!/bin/bash

export REDIS_PASSWORD=`echo -n ${REDIS_PASSWORD_PLAIN} | base64`

export PGPASS=`echo -n ${PGPASS_PLAIN} | base64`
export PGADMIN_USER=`echo -n ${PGADMIN_USER_PLAIN} | base64`
export PGADMIN_PASS=`echo -n $PGADMIN_PASS_PLAIN | base64`

source ./scripts/common.sh
CMD="${1:-apply}"
SERVICE=$2
PLATFORM="${3:-local}"
NS="services"

case $CMD in
    apply)
        # kubectl apply -f manifests/storage/storage.${PLATFORM}.yaml
        apply $SERVICE $PLATFORM $NS
        ;;

    delete)
        delete $SERVICE $PLATFORM $NS
        ;;
    *)
        echo "Use apply or delete"
        exit 1
        ;;
esac



