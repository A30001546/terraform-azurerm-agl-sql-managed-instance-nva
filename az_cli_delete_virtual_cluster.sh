#!/bin/bash

# Requires the following variables exported
#  ARM_CLIENT_ID
#  ARM_CLIENT_SECRET
#  ARM_TENANT_ID

# Extract input args
SUBSCRIPTION_ID=$1
resourceGroup=$2
subnetID=$3
#ARM_CLIENT_ID=f8e0cf78-dd47-4e68-ab0a-ac72c4b9e73d
#ARM_CLIENT_SECRET=9P+dWDuosXFoCX3VNPJl0O4DybD85anYy6xl5hbQsTU=
#ARM_TENANT_ID=123913b9-915d-4d67-aaf9-ce327e8fc59f 

echo $subnetID

# Log into azure
az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID 1>/dev/null
# Grab the current sub
az account set -s $SUBSCRIPTION_ID

virtualCluster=`az sql virtual-cluster list -g $resourceGroup --query "[?contains(subnetId, '$subnetID')].name" -o tsv`
echo hello
echo $virtualCluster

# Delete virtual cluster
az sql virtual-cluster delete -g $resourceGroup -n $virtualCluster