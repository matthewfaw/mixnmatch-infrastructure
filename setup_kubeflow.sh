#!/bin/bash
set -e

#KFAPP=$1
CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_k8s_istio.v1.0.1.yaml"

#echo "KFAPP: $KFAPP"

mkdir -p kubeflow
cd kubeflow

#kfctl init ${KFAPP}

#cd ${KFAPP}
kfctl apply -V -f ${CONFIG_URI}
