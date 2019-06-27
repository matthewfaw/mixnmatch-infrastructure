#!/bin/bash

BASE_OUT=monitoring/generated
PROMETHEUS_CHART_NAME=stable/prometheus
PROMETHEUS_VALUES=monitoring/prometheus_values.yaml
PROMETHEUS_INSTALL_ALL=${BASE_OUT}/helm_prometheus.out
PROMETHEUS_INSTALL_YAML=${BASE_OUT}/prometheus.yaml
PROMETHEUS_VERSION=8.11.4
PROMETHEUS_NAME=canela-prom

GRAFANA_CHART_NAME=stable/grafana
GRAFANA_VALUES=monitoring/grafana_values.yaml
GRAFANA_VALUES_TEMP=monitoring/templated_grafana_values.yaml
GRAFANA_INSTALL_ALL=${BASE_OUT}/helm_grafana.out
GRAFANA_INSTALL_YAML=${BASE_OUT}/grafana.yaml
GRAFANA_VERSION=3.4.2
GRAFANA_NAME=canela-graf
if [ -z "$GRAFANA_ADMIN_PW" ]; then
    echo "No default admin pw found. Generating a random one"
    GRAFANA_ADMIN_PW=$(openssl rand -base64 32 | base64)
fi
ADMIN_PW=$(echo $GRAFANA_ADMIN_PW | base64 -D)

mkdir -p $BASE_OUT

helm install $PROMETHEUS_CHART_NAME --dry-run --debug\
    -f $PROMETHEUS_VALUES\
    --version $PROMETHEUS_VERSION\
    --wait\
    --namespace helm\
    --name $PROMETHEUS_NAME > $PROMETHEUS_INSTALL_ALL

MANIFEST_LINE=$(grep -n "MANIFEST:" ${PROMETHEUS_INSTALL_ALL} | cut -d: -f1 | head -n 1)
cat ${PROMETHEUS_INSTALL_ALL} |\
    sed -n "$((MANIFEST_LINE + 1)),$ p" |\
    sed "s/namespace: helm/namespace: default/g" |\
    sed "s/namespace=\"helm\"/namespace=\"default\"/g" |\
    sed "s/- \"helm\"/- \"default\"/g" |\
    sed "s/regex: helm/regex: default/g" |\
    sed "s/helm\.svc/default.svc/g" |\
    sed "s/helm:/default:/g" > ${PROMETHEUS_INSTALL_YAML}

echo "About to apply the prometheus manifests in ${PROMETHEUS_INSTALL_YAML}."
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

cat $GRAFANA_VALUES |\
    sed "s|<ADMIN_PASSWORD>|${ADMIN_PW}|g" |\
    sed "s/<PROMETHEUS_NAME>/${PROMETHEUS_NAME}/g" > $GRAFANA_VALUES_TEMP

helm install $GRAFANA_CHART_NAME --dry-run --debug\
    -f $GRAFANA_VALUES_TEMP\
    --version $GRAFANA_VERSION\
    --wait\
    --namespace helm\
    --name $GRAFANA_NAME > $GRAFANA_INSTALL_ALL

MANIFEST_LINE=$(grep -n "MANIFEST:" ${GRAFANA_INSTALL_ALL} | cut -d: -f1 | head -n 1)
cat ${GRAFANA_INSTALL_ALL} |\
    sed -n "$((MANIFEST_LINE + 1)),$ p" |\
    sed "s/namespace: helm/namespace: default/g" |\
    sed "s/namespace=\"helm\"/namespace=\"default\"/g" |\
    sed "s/- \"helm\"/- \"default\"/g" |\
    sed "s/regex: helm/regex: default/g" |\
    sed "s/helm\.svc/default.svc/g" |\
    sed "s/helm:/default:/g" > ${GRAFANA_INSTALL_YAML}

echo "About to apply the grafana manifests in ${GRAFANA_INSTALL_YAML}."
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

kubectl apply -f ${BASE_OUT}
