# 201-azurestack-harbor-registry

## validate

```bash
SSHKEY=$(cat ~/.ssh/id_rsa.pub)
DNS_LABEL_PREFIX=harbor1
```

```bash

az group create --name ${DNS_LABEL_PREFIX} --location local
az deployment group validate --resource-group ${DNS_LABEL_PREFIX} \
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData="$(cat ~/.ssh/id_rsa.pub)" \
    HostDNSLabelPrefix=${DNS_LABEL_PREFIX}
```

## deploy

```bash
az group deployment create --resource-group harbor \
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData="$(cat ~/.ssh/id_rsa.pub)"
```

### using external hostname and certificate:

EXTERNAL_HOSTNAME=harbor2.home.labbuldr.com
```bash
az group create --name ${DNS_LABEL_PREFIX} --location local

az deployment group validate --resource-group ${DNS_LABEL_PREFIX}\
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData="$(cat ~/.ssh/id_rsa.pub)" \
    HostDNSLabelPrefix=${DNS_LABEL_PREFIX} \
    caCert="$(cat ~/workspace/.acme.sh/home.labbuildr.com/ca.cer)" \
    hostCert="$(cat ~/workspace/.acme.sh/home.labbuildr.com/home.labbuildr.com.cer)" \
    certKey="$(cat ~/workspace/.acme.sh/home.labbuildr.com/home.labbuildr.com.key)" \
    externalHostname=harbor2.home.labbuildr.com
```
```
az deployment group create --resource-group ${DNS_LABEL_PREFIX}\
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData="$(cat ~/.ssh/id_rsa.pub)" \
    HostDNSLabelPrefix=${DNS_LABEL_PREFIX} \
    caCert="$(cat ~/workspace/.acme.sh/home.labbuildr.com/ca.cer)" \
    hostCert="$(cat ~/workspace/.acme.sh/home.labbuildr.com/home.labbuildr.com.cer)" \
    certKey="$(cat ~/workspace/.acme.sh/home.labbuildr.com/home.labbuildr.com.key)" \
    externalHostname=harbor2.home.labbuildr.com
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
    accountkey=${AZS_STORAGE_ACCOUNT_KEY} \
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
    accountkey=${AZS_STORAGE_ACCOUNT_KEY} \
    accountname=${AZS_STORAGE_ACCOUNT_NAME}
```

