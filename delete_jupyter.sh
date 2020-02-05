#!/bin/bash
set -e

DATASET_ID=$1
NB_ID=$2

DATASET_ID_LOWER=$(echo $DATASET_ID | tr '[:upper:]' '[:lower:]')

echo "Deleting any old notebooks of the same name"
cat jupyter/notebook.yaml |\
    sed "s/<DATASET_ID_LOWER>/${DATASET_ID_LOWER}/g" |\
    sed "s/<NB_ID>/${NB_ID}/g" |\
    kubectl delete -f - || true
