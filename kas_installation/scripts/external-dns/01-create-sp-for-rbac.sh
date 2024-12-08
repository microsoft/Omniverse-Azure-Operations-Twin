#!/bin/bash
SUBSCRIPTION_ID="60762596-e998-40df-8b39-796ed1f4f2ee"
EXTERNALDNS_NEW_SP_NAME="OVASExtrernalDNSSP" # name of the service principal
AZURE_DNS_ZONE_RESOURCE_GROUP="rg-amata-msft-pal" # name of resource group where dns zone is hosted
AZURE_DNS_ZONE="ovas.omniverse.nvidia.com" # DNS zone name like example.com or sub.example.com

# Create the service principal
DNS_SP=$(az ad sp create-for-rbac --name $EXTERNALDNS_NEW_SP_NAME)
EXTERNALDNS_SP_APP_ID=$(echo $DNS_SP | jq -r '.appId')
EXTERNALDNS_SP_PASSWORD=$(echo $DNS_SP | jq -r '.password')
echo "Client ID: ${EXTERNALDNS_SP_APP_ID}"
echo "Client secret: ${EXTERNALDNS_SP_PASSWORD}"

DNS_ID=$(az network dns zone show --name $AZURE_DNS_ZONE \
 --subscription $SUBSCRIPTION_ID --resource-group $AZURE_DNS_ZONE_RESOURCE_GROUP --query "id" --output tsv)
echo "DNS ID: ${DNS_ID}"

az role assignment create --role "Reader" --assignee $EXTERNALDNS_SP_APP_ID --scope $DNS_ID
az role assignment create --role "Contributor" --assignee $EXTERNALDNS_SP_APP_ID --scope $DNS_ID

echo "Copy azure.json.template to azure.json and add the above client ID, secret, resource group and subscription ID" 