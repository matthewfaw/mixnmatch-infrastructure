#!/bin/bash
set -e

EXISTING_CLAIM=$1
JENKINS_BACKUP_BUCKET=$2

echo "Creating PersistentVolumeClaim $EXISTING_CLAIM"
cat jenkins/pvc.yaml |\
    sed "s/<EXISTING_CLAIM>/${EXISTING_CLAIM}/g" |\
    kubectl apply -f -

echo "Creating job to restore Jenkins backup from $JENKINS_BACKUP_BUCKET"
cat jenkins/restore/restore.yaml |\
    sed "s/<EXISTING_CLAIM>/${EXISTING_CLAIM}/g" |\
    sed "s|<JENKINS_BACKUP_BUCKET>|${JENKINS_BACKUP_BUCKET}|g" |\
    kubectl apply -f - || true

echo "Waiting for the job to finish"
kubectl wait --for=condition=complete job/restore-jenkins --timeout=-1s
echo "Determined that the job is complete!"
