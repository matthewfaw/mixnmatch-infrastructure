#!/bin/bash
set -e

GCLOUD_SVC_ACCOUNT_FILE=$1
KAGGLE_CREDS_FILE=$2
GIT_PRIVATE_CREDS_FILE=$3
GIT_KNOWN_HOSTS_FILE=$4
# Note this email address is not used, but is required
GCLOUD_EMAIL="user@example.com"

if [ -z "${GCLOUD_SVC_ACCOUNT_FILE}" ]; then
    echo "Missing GCloud service account file! Cannot continue."
    exit 1
elif [ -z "${KAGGLE_CREDS_FILE}" ]; then
    echo "Missing Kaggle credentials file!"
    exit 1
elif [ -z "${GIT_PRIVATE_CREDS_FILE}" ]; then
    echo "Missing Git credentials file!"
    exit 1
fi

DOCKER_CREDS_ENC=$(kubectl create secret docker-registry docker-creds \
  --docker-server=https://gcr.io \
  --docker-username=_json_key \
  --docker-email=${GCLOUD_EMAIL} \
  --docker-password="$(cat ${GCLOUD_SVC_ACCOUNT_FILE})" \
  --dry-run -o json |\
  jq -r '.data[".dockerconfigjson"]')

cat secrets/secrets.yaml |\
    sed "s/<GCLOUD_CREDS>/$(cat $GCLOUD_SVC_ACCOUNT_FILE | base64)/g" |\
    sed "s/<KAGGLE_CREDS>/$(cat $KAGGLE_CREDS_FILE | base64)/g" |\
    sed "s/<DOCKER_CREDS>/${DOCKER_CREDS_ENC}/g" |\
    sed "s/<GIT_PRIVATE_SSH_KEY>/$(cat $GIT_PRIVATE_CREDS_FILE | base64)/g" |\
    sed "s/<KNOWN_HOSTS>/$(cat ${GIT_KNOWN_HOSTS_FILE} | grep "github.com" | base64)/g" |\
    kubectl apply -f -

