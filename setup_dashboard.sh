#!/bin/bash
set -e

URL="https://raw.githubusercontent.com/kubernetes/dashboard/v1.10.1/src/deploy/recommended/kubernetes-dashboard.yaml"
BASE=dashboard
DASHBOARD_YAML=${BASE}/dashboard.yaml

echo "Creating the dashboard from $URL"
curl $URL > $DASHBOARD_YAML
echo "Here's the yaml we'll use:"
cat $DASHBOARD_YAML

echo "Note that we will also set up a dashboard user to access the dashboard"

kubectl apply -f ${BASE}/
