#!/bin/bash
set -e

GCLOUD_SVC_ACCOUNT_FILE=$1
KAGGLE_CREDS_FILE=$2
GIT_PRIVATE_CREDS_FILE=$3
GIT_KNOWN_HOSTS_FILE=$4
SETUP_TYPE=$5
EXISTING_JENKINS_PVC=$6
HELM_NAMESPACE=helm
LOCAL_CONTEXT=minikube
if [[ -z "$JENKINS_BACKUP_BUCKET" ]]; then
    echo "Jenkins backup bucket env var not set! Cannot proceed."
    exit 1
else
    echo "Using Jenkins backup bucket: $JENKINS_BACKUP_BUCKET"
fi
KFAPP=kf-canela-cocoa
if [[ -z "$GKE_CLUSTER_NAME" ]]; then
    echo "GKE Cluster name is empty! Cannot proceed."
    exit 1
else
    echo "Using GKE Cluster name: $GKE_CLUSTER_NAME"
fi

if [[ "$SETUP_TYPE" = "local" ]] || [[ "$SETUP_TYPE" = "gcloud" ]] || [[ "$SETUP_TYPE" = "hybrid" ]]; then
    echo "Using setup $SETUP_TYPE"
else
    echo "Invalid setup type.  Must be (local|gcloud|hybrid)"
    exit 1
fi

if [[ "$SETUP_TYPE" = "local" ]] || [[ "$SETUP_TYPE" = "hybrid" ]]; then
    echo "Creating local setup with k8s context $LOCAL_CONTEXT"
    kubectl config use-context $LOCAL_CONTEXT
    ./setup_helm.sh $HELM_NAMESPACE
    ./setup_secrets.sh $GCLOUD_SVC_ACCOUNT_FILE $KAGGLE_CREDS_FILE $GIT_PRIVATE_CREDS_FILE $GIT_KNOWN_HOSTS_FILE
    ./setup_experiment_roles.sh
    if [[ -z "$EXISTING_JENKINS_PVC" ]]; then
        echo "No Existing jenkins pvc arg provided. Creating a new one"
    else
        echo "Creating PVC ${EXISTING_JENKINS_PVC}"
        ./setup_existing_pvc.sh ${EXISTING_JENKINS_PVC} ${JENKINS_BACKUP_BUCKET}
    fi
    ./setup_jenkins.sh "${EXISTING_JENKINS_PVC}" $HELM_NAMESPACE
    ./backup_jenkins.sh ${JENKINS_BACKUP_BUCKET} ${EXISTING_JENKINS_PVC:-canela-jenkins}
    ./setup_monitoring.sh
fi
if [[ "$SETUP_TYPE" = "gcloud" ]] || [[ "$SETUP_TYPE" = "hybrid" ]]; then
    echo "Creating gcloud setup"
    ./setup_gke.sh $GKE_CLUSTER_NAME
    ./setup_dashboard.sh
    ./setup_kubeflow.sh $KFAPP
fi
