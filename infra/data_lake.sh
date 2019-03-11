#!/bin/bash

DATA_LAKE_RG='datalake-template'
DATA_LAKE_LOCATION='westeurope'
DATA_LAKE_STORAGE='datalakestorage'
DATA_LAKE_WORKFLOW='dataorchestrator'

ARM_LOCATION='arm/datafactory.json'
ARM_PROPS_LOCATION='../conf/data_factory_prop.json'

# Create Resource Group
az group create \
    --name $DATA_LAKE_RG \
    --location $DATA_LAKE_LOCATION 

# Create Storage (ADLS Gen2) Account
az storage account create \
   --name $DATA_LAKE_STORAGE  \
   --resource-group $DATA_LAKE_RG  \
   --location $DATA_LAKE_LOCATION  \
   --sku Standard_LRS \
   --kind StorageV2  \
   --hierarchical-namespace true

 # Create Data Factory Version 2 
az group deployment create \
	--name $DATA_LAKE_WORKFLOW \
        --resource-group $DATA_LAKE_RG \
	--template-file $ARM_LOCATION \
	--parameters $ARM_PROPS_LOCATION
