#!/bin/bash
set -e

KFAPP=$1

echo "KFAPP: $KFAPP"

mkdir -p kubeflow
cd kubeflow

kfctl init ${KFAPP}

cd ${KFAPP}
kfctl generate all -V
kfctl apply all -V
