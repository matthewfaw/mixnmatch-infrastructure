#!/bin/bash
set -e

HELM_NAMESPACE=${1-helm}

brew install kubernetes-helm || true

echo "Installing the Helm Tiller in the ${HELM_NAMESPACE} ns to the following k8s cluster:"
kubectl config current-context
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
echo "Setting up resources for helm"
kubectl apply -f helm/
echo "Updating the helm repos"
helm repo update
echo "Initializing helm"
helm init --history-max 200\
    --tiller-namespace ${HELM_NAMESPACE}\
    --service-account=tiller\
    --wait
