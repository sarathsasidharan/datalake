#!/bin/bash

DATA_LAKE_RG='datalake-template'
DATA_LAKE_LOCATION='westeurope'
DATA_LAKE_STORAGE='datalakestorage'
DATA_LAKE_WORKFLOW='datalakeorchestrator'
DATA_LAKE_WORKFLOW_DB='datalakeprepengine'


ARM_LOCATION='arm/data_factory.json'
ARM_PROPS_LOCATION='../conf/data_factory_prop.json'

DATA_LAKE_SERVER_NAME='datalakerelationaldb'
ADMIN_USERNAME='sasasid'
ADMIN_PASSWD='Bigdata@123'
DATA_LAKE_DATABASE_NAME='datalakerelational'
DATA_LAKE_DWH_NAME='datalakedwh'

ARM_LOCATION_DB='arm/databricks.json'
ARM_PROPS_LOCATION_DB='../conf/databricks_prop.json'

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

## Create a logical server in the resource group
az sql server create \
 --name $DATA_LAKE_SERVER_NAME \
 --resource-group $DATA_LAKE_RG \
 --location $DATA_LAKE_LOCATION  \
 --admin-user $ADMIN_USERNAME \
 --admin-password $ADMIN_PASSWD

## Create a database in the server 
az sql db create \
 --resource-group $DATA_LAKE_RG \
 --server $DATA_LAKE_SERVER_NAME \
 --name $DATA_LAKE_DATABASE_NAME \
 --sample-name AdventureWorksLT \
 --service-objective S0

# Configure a firewall rule for the server
az sql server firewall-rule create \
 --resource-group $DATA_LAKE_RG \
 --server $DATA_LAKE_SERVER_NAME \
 -n AllowYourIp \
 --start-ip-address 0.0.0.0 \
 --end-ip-address 0.0.0.0

  # Create Azure Databricks 
az group deployment create \
	--name $DATA_LAKE_WORKFLOW_DB \
        --resource-group $DATA_LAKE_RG \
	--template-file $ARM_LOCATION_DB \
	--parameters $ARM_PROPS_LOCATION_DB


# Create a SQL Datawarehouse
az sql dw create --name $DATA_LAKE_DWH_NAME
                 --resource-group $DATA_LAKE_RG
                 --server $DATA_LAKE_SERVER_NAME