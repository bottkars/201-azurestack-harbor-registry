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
