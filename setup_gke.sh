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

if [ -z "${GCE_ADMIN_ACCESS_CIDR}" ]; then
    echo "Missing environment variable GCE_ADMIN_ACCESS_CIDR. Cannot continue. You can set this variable as an environment variable"
    exit 1
else
    echo "Using admin access cidr: ${GCE_ADMIN_ACCESS_CIDR}"
fi

echo "Creating a GKE cluster with name $GKE_CLUSTER_NAME"
gcloud container clusters create ${GKE_CLUSTER_NAME} \
    --zone us-west1-b \
    --disk-size 40 \
    --preemptible \
    --machine-type n1-standard-4 \
    --enable-master-authorized-networks \
    --master-authorized-networks ${GCE_ADMIN_ACCESS_CIDR} \
    --enable-autoscaling \
    --num-nodes 3 \
    --min-nodes 0 \
    --max-nodes 5
