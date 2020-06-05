#!/bin/bash
set -e

KUBEFLOW_SRC=$1

if [[ -z "$KUBEFLOW_SRC" ]]; then
    echo "Kubeflow source dir not specified. Cannot proceed."
    exit 1
fi

echo "Deleting the $KUBEFLOW_SRC directory."
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
rm -rf $KUBEFLOW_SRC
mkdir $KUBEFLOW_SRC
cd $KUBEFLOW_SRC

TAR_NAME="kubeflow.tar.gz"
curl -L https://github.com/kubeflow/kfctl/archive/v1.0.1.zip --output $TAR_NAME
tar -xzvf $TAR_NAME
rm $TAR_NAME
cd kfctl*
cd cmd/kfctl
go build
mv kfctl /usr/local/bin/