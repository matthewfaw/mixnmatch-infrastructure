#!/bin/bash

nohup minikube dashboard &
MINIKUBE_PID=$!
nohup kubectl port-forward svc/canela-jenkins 8080 &
JENKINS_PID=$!

echo "Minikube PID: ${MINIKUBE_PID}"
echo "Jenkins PID: ${JENKINS_PID}"
