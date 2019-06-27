#!/bin/bash

secret=$(kubectl get sa dashboard-user -o json | jq -r '.secrets[0].name')
kubectl get secret $secret -o json | jq -r '.data.token' | base64 -D | pbcopy