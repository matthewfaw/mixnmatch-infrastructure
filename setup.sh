#!/bin/bash
set -e

## To run:
## Suppose:
# - gcloud creds are in ~/.gcloud_creds/<CREDS_FILENAME>.json
# - kaggle creds are in ~/.kaggle/<CREDS_FILENAME>.json
# - git ssh creds are in ~/.ssh/id_rsa_<...>
# - git known hosts are in ~/.ssh/known_hosts
# - existing Jenkins pvc is called "restored-jenkins"
## Then run:
# ./setup.sh ~/.gcloud_creds/<CREDS_FILENAME>.json ~/.kaggle/<CREDS_FILENAME>.json ~/.ssh/id_rsa_<...> ~/.ssh/known_hosts restored-jenkins

GCLOUD_SVC_ACCOUNT_FILE=$1
KAGGLE_CREDS_FILE=$2
GIT_PRIVATE_CREDS_FILE=$3
GIT_KNOWN_HOSTS_FILE=$4
EXISTING_JENKINS_PVC=$5
HELM_NAMESPACE=helm
if [[ -z "$JENKINS_BACKUP_BUCKET" ]]; then
    echo "Jenkins backup bucket env var not set! Cannot proceed."
    exit 1
else
    echo "Using Jenkins backup bucket: $JENKINS_BACKUP_BUCKET"
fi
#KFAPP=kf-canela-cocoa
KUBEFLOW_SRC=~/.kubeflow
if [[ -z "$GKE_CLUSTER_NAME" ]]; then
    echo "GKE Cluster name is empty! Cannot proceed."
    exit 1
else
    echo "Using GKE Cluster name: $GKE_CLUSTER_NAME"
fi

echo "Creating gcloud setup"
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
./setup_gke.sh $GKE_CLUSTER_NAME
echo "Downloading kfctl"
read -p "Is this ok (y/n)? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # do dangerous stuff
    echo "Proceeding..."
    ./setup_kfctl.sh $KUBEFLOW_SRC
else
    echo "Ok. Skipping the download and proceeding."
fi
echo "Setting up kubeflow."
read -p "Is this ok (y/n)? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # do dangerous stuff
    echo "Proceeding..."
    ./setup_kubeflow.sh
else
    echo "Ok. Skipping the download and proceeding."
fi
./setup_secrets.sh $GCLOUD_SVC_ACCOUNT_FILE $KAGGLE_CREDS_FILE $GIT_PRIVATE_CREDS_FILE $GIT_KNOWN_HOSTS_FILE
./setup_experiment_roles.sh
./setup_helm.sh $HELM_NAMESPACE
./setup_dashboard.sh
if [[ -z "$EXISTING_JENKINS_PVC" ]]; then
    echo "No Existing jenkins pvc arg provided. Creating a new one"
else
    echo "Creating PVC ${EXISTING_JENKINS_PVC}"
    ./setup_existing_pvc.sh ${EXISTING_JENKINS_PVC} ${JENKINS_BACKUP_BUCKET}
fi
./setup_jenkins.sh "${EXISTING_JENKINS_PVC}" $HELM_NAMESPACE
./backup_jenkins.sh ${JENKINS_BACKUP_BUCKET} ${EXISTING_JENKINS_PVC:-canela-jenkins}
./setup_monitoring.sh
