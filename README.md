# 201-azurestack-harbor-registry

## validate

```bash

az group create --name harbor --location local
az group deployment validate --resource-group harbor \
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData=${SSHKEY}
```

## deploy

```bash
az group deployment create --resource-group harbor \
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData=${SSHKEY}
```



### using Azurestack Storage Backend

But your Cert into a Variable

```bash
CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ~/Desktop/certs/root.pem)
```

```bash
az group create --name harbor --location local
az group deployment validate --resource-group harbor \
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData=${SSHKEY} \
    rootCA=${CERT} \
    container=${AZS_STORAGE_CONTAINER} \
    accountkey=${AZS_STORAGE_ACCOUNTKEY} \
    accountname=${AZS_STORAGE_ACCOUNT_NAME}
```

```bash
az group create --name harbor --location local
az group deployment create --resource-group harbor \
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData=${SSHKEY} \
    rootCA=${CERT} \
    container=${AZS_STORAGE_CONTAINER} \
    accountkey=${AZS_STORAGE_ACCOUNTKEY} \
    accountname=${AZS_STORAGE_ACCOUNT_NAME}
```

