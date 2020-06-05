#!/bin/bash
set -e

if [[ -z "$GKE_CLUSTER_NAME" ]]; then
    echo "GKE Cluster name is empty! Cannot proceed."
    exit 1
else
    echo "Using GKE Cluster name: $GKE_CLUSTER_NAME"
fi

IP_TO_ADD="$(./current_ip.sh)"

echo "Adding IP $IP_TO_ADD to cluster $GKE_CLUSTER_NAME"
read -p "Is this ok (y/n)? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # do dangerous stuff
    echo "Proceeding..."
else
    echo "Ok. Exiting"
    exit 1
fi

gcloud container clusters update $GKE_CLUSTER_NAME \
   --enable-master-authorized-networks \
   --master-authorized-networks $IP_TO_ADD
