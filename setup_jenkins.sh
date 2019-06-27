#!/bin/bash
set -e

PREVIOUS_PVC=$1
HELM_NAMESPACE=${2:-helm}
# Note, if this isn't set, then a default one will be generated
ADMIN_PW=$(echo $JENKINS_ADMIN_PW | base64 -D)
JENKINS_PERMISSIONS_YAML=jenkins/rbac.yaml
JENKINS_HELM_VERSION=1.1.23
JENKINS_NAME=canela
SRC_JENKINS_VALUES=jenkins/values.yaml
FINAL_JENKINS_VALUES=jenkins/templated_values.yaml
BASE_OUT=jenkins/generated
JENKINS_INSTALL_ALL=${BASE_OUT}/helm.out
JENKINS_INSTALL_YAML=${BASE_OUT}/jenkins.yaml

#echo "Setting up the permissions for Jenkins"
#kubectl apply -f ${JENKINS_PERMISSIONS_YAML}

echo "Creating the artifact dir for jenkins helm outputs"
mkdir -p ${BASE_OUT}

echo "Replacing templated values in ${SRC_JENKINS_VALUES}"
cat ${SRC_JENKINS_VALUES} |\
    sed "s/<EXISTING_CLAIM>/${PREVIOUS_PVC}/g" |\
    sed "s/<ADMIN_PASSWORD>/${ADMIN_PW}/g" > ${FINAL_JENKINS_VALUES}

echo "Populating the jenkins helm template"
helm install stable/jenkins --dry-run --debug\
    -f ${FINAL_JENKINS_VALUES}\
    --version ${JENKINS_HELM_VERSION}\
    --wait\
    --namespace ${HELM_NAMESPACE}\
    --name ${JENKINS_NAME} > ${JENKINS_INSTALL_ALL}

MANIFEST_LINE=$(grep -n "MANIFEST:" ${JENKINS_INSTALL_ALL} | cut -d: -f1 | head -n 1)
cat ${JENKINS_INSTALL_ALL} |\
    sed -n "$((MANIFEST_LINE + 1)),$ p" |\
    sed "s/namespace: helm/namespace: default/g" |\
    sed "s/helm\.svc/default.svc/g" |\
    sed "s/helm:/default:/g" > ${JENKINS_INSTALL_YAML}

echo "About to apply the jenkins manifests in ${JENKINS_INSTALL_YAML}."
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

kubectl apply -f ${JENKINS_INSTALL_YAML}
