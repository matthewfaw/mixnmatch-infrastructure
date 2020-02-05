#!/bin/bash
set -e

DATASET_ID=$1
NB_ID=$2
EXPERIMENT_ID=$3

if [[ -z "$DATASET_ID" ]]; then
    echo "Must provide DATASET_ID"
    exit 1
elif [[ "$DATASET_ID" != allstate ]] && [[ "$DATASET_ID" != wine ]] && [[ "$DATASET_ID" != amazon ]]; then
    echo "$DATASET_ID is invalid!"
    exit 1
fi

DATASET_ID_LOWER=$(echo $DATASET_ID | tr '[:upper:]' '[:lower:]')

./delete_jupyter.sh $DATASET_ID $NB_ID

echo "Creating jupyter deployment for dataset id $DATASET_ID"

if [[ -z "$GIT_REPO_SSH" ]]; then
    echo "Git repo ssh is empty! Cannot proceed."
    exit 1
else
    echo "Using git repo ssh: $GIT_REPO_SSH"
fi
if [[ -z "$GIT_BRANCH" ]]; then
    echo "Git branch is empty! Cannot proceed."
    exit 1
else
    echo "Using git branch name: $GIT_BRANCH"
fi
REPO_NAME=$(echo $GIT_REPO_SSH | sed "s|.*/||g" | sed "s/\.git//g")
if [[ -z "$EXPERIMENT_ID" ]]; then
    echo "Experiment id is empty, so copying all experiment results"
    BUCKET_SUBPATHS=""
else
    echo "Determined experiment id to be: $EXPERIMENT_ID. Copying only this experiment data"
    BUCKET_SUBPATHS="${EXPERIMENT_ID}"
fi
if [[ -z "$GCLOUD_DATASET_BUCKET" ]]; then
    echo "Gcloud dataset bucket base is empty! Cannot proceed."
    exit 1
else
    echo "Using Gcloud dataset bucket base: $GCLOUD_DATASET_BUCKET"
fi
GCLOUD_EXP_BASE="${GCLOUD_DATASET_BUCKET}/${DATASET_ID}/experiment_running"

cat jupyter/notebook.yaml |\
    sed "s/<DATASET_ID_LOWER>/${DATASET_ID_LOWER}/g" |\
    sed "s|<GIT_REPO>|${GIT_REPO_SSH}|g" |\
    sed "s/<BRANCH>/${GIT_BRANCH}/g" |\
    sed "s/<REPO_NAME>/${REPO_NAME}/g" |\
    sed "s/<NB_ID>/${NB_ID}/g" |\
    sed "s|<GCLOUD_EXP_BASE>|${GCLOUD_EXP_BASE}|g" |\
    sed "s|<BUCKET_SUBPATHS>|${BUCKET_SUBPATHS}|g" |\
    kubectl apply -f -

echo "Waiting for deployment to be available:"
kubectl wait --for=condition=available deployment/jupyter-notebook-${DATASET_ID_LOWER}-${NB_ID} --timeout=-1s
