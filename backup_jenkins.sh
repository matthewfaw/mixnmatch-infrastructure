#!/bin/bash
set -e

JENKINS_BACKUP_BUCKET=$1
JENKINS_PVC=$2

echo "Creating backup cronjob for Jenkins. Backups will be saved in $JENKINS_BACKUP_BUCKET"

cat jenkins/backup/backup.yaml |\
    sed "s|<JENKINS_BACKUP_BUCKET>|${JENKINS_BACKUP_BUCKET}|g" |\
    sed "s/<JENKINS_PVC>/${JENKINS_PVC}/g" |\
    kubectl apply -f -
