#!/bin/bash
set -e

PROJECT=$1
COMMIT_FIRST_7=$2
BRANCH=$3
BUILD_NUMBER=$4

TAG=${BRANCH}-${BUILD_NUMBER}-${COMMIT_FIRST_7}

echo "Building Dockerfile with tag ${TAG}"

docker build -t gcr.io/${PROJECT}/cloud-sdk:latest -t gcr.io/${PROJECT}/cloud-sdk:${TAG} .
docker push gcr.io/${PROJECT}/cloud-sdk:latest
docker push gcr.io/${PROJECT}/cloud-sdk:${TAG}
