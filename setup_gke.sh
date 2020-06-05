#!/bin/bash
set -e

GKE_CLUSTER_NAME=$1

if [ -z "${GKE_CLUSTER_NAME}" ]; then
    echo "GKE cluster name not provided! Cannot proceed"
    exit 1
else
    echo "Trying to creater GKE cluster $GKE_CLUSTER_NAME"
fi

CLUSTER_EXISTS=$(gcloud container clusters list --filter=${GKE_CLUSTER_NAME} | wc -l | sed "s/ //g")
if [ "$CLUSTER_EXISTS" = 0 ]; then
    echo "Determined that no cluster exists, so proceeding to create"
else
    echo "Determined that the cluster with name $GKE_CLUSTER_NAME already exists. Exiting peacefully without recreating"
    exit 0
fi

IP_TO_ADD="$(./current_ip.sh)"
echo "Adding your current IP (${IP_TO_ADD}) as the authorized IP for this cluster."
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

echo "Creating a GKE cluster with name $GKE_CLUSTER_NAME"
gcloud container clusters create ${GKE_CLUSTER_NAME} \
    --zone us-west1-b \
    --disk-size 40 \
    --preemptible \
    --machine-type n1-standard-4 \
    --enable-master-authorized-networks \
    --master-authorized-networks ${IP_TO_ADD} \
    --enable-autoscaling \
    --num-nodes 3 \
    --min-nodes 0 \
    --max-nodes 5
