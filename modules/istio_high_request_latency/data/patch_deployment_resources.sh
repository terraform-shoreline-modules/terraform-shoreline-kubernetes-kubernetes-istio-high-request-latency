

#!/bin/bash



# Set variables

DEPLOYMENT_NAME=${DEPLOYMENT_NAME}

RESOURCE_NAME=${RESOURCE_NAME}

RESOURCE_VALUE=${RESOURCE_VALUE}

# Use kubectl patch to patch the deployment
kubectl patch deployment $DEPLOYMENT_NAME -p '{"spec":{"template":{"spec":{"containers":{"resources":[{"limits":{"'$RESOURCE_NAME'":"'$RESOURCE_VALUE'"}, "requests":{"'$RESOURCE_NAME'":"'$RESOURCE_VALUE'"}}]}}}}}'