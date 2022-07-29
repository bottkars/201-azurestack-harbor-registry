# 201-azurestack-harbor-registry

This template deploys a Basic Harbor Container registry with HTTPS Support on Azure Stack
It supports generation og self-signed certificates OR use of Custom Certificates

when Using external Certificates, an external DNS Name can be used as well ( needs to be configured in your DNS ) 


## basic deployment using self-signed certificates

```bash
DNS_LABEL_PREFIX=devregistry # this should be the azurestack cloudapp dns name , e.g. Harbor, Mandatory
```
### Template Validation
```bash
az group create --name ${DNS_LABEL_PREFIX:?variable is empty} --location local
az deployment group validate --resource-group ${DNS_LABEL_PREFIX:?variable is empty} \
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData="$(cat ~/.ssh/id_rsa.pub)" \
    HostDNSLabelPrefix=${DNS_LABEL_PREFIX:?variable is empty}
```

### Template deployment

```bash
az  deployment group create --resource-group  ${DNS_LABEL_PREFIX:?variable is empty} \
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData="$(cat ~/.ssh/id_rsa.pub)" \
    HostDNSLabelPrefix=${DNS_LABEL_PREFIX:?variable is empty}
```

### cleaning up
```bash
az group delete --name ${DNS_LABEL_PREFIX:?variable is empty} --yes
```


### using external hostname and user Provided certificate:
```bash
DNS_LABEL_PREFIX=registry #dns host label prefix 
EXTERNAL_HOSTNAME=registry.home.labbuldr.com #external dns name

az group create --name ${DNS_LABEL_PREFIX:?variable is empty} --location local

az deployment group validate --resource-group ${DNS_LABEL_PREFIX:?variable is empty}\
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData="$(cat ~/.ssh/id_rsa.pub)" \
    HostDNSLabelPrefix=${DNS_LABEL_PREFIX:?variable is empty} \
    caCert="$(cat ~/Downloads/Acmecert.crt)" \
    hostCert="$(cat ~/Downloads/home.labbuildr.com.crt)" \
    certKey="$(cat ~/Downloads/home.labbuildr.com.key)" \
    externalHostname=${EXTERNAL_HOSTNAME:?variable is empty}
```

```bash
az deployment group create --resource-group ${DNS_LABEL_PREFIX:?variable is empty}\
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData="$(cat ~/.ssh/id_rsa.pub)" \
    HostDNSLabelPrefix=${DNS_LABEL_PREFIX:?variable is empty} \
    caCert="$(cat ~/Downloads/Acmecert.crt)" \
    hostCert="$(cat ~/Downloads/home.labbuildr.com.crt)" \
    certKey="$(cat ~/Downloads/home.labbuildr.com.key)" \
    externalHostname=${EXTERNAL_HOSTNAME:?variable is empty}
```    
## Troubleshooting




## THIS IS STILL TBD AND SUBJECT TO TESTING


### using Azurestack Storage Backend

Put your Cert into a Variable

```bash
CERT=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' ~/Downloads/root.pem)
DNS_LABEL_PREFIX=registry #dns host label prefix 
EXTERNAL_HOSTNAME=registry.home.labbuldr.com #external dns name
AZS_STORAGE_CONTAINER=registry
AZS_STORAGE_ACCOUNT_NAME=opsmanagerimage
AZS_DOMAIN=local.azurestack.external
```

```bash
az group create --name harbor --location local
az group deployment validate --resource-group harbor \
    --template-uri "https://raw.githubusercontent.com/bottkars/201-azurestack-harbor-registry/master/azuredeploy.json" \
    --parameters \
    sshKeyData="$(cat ~/.ssh/id_rsa.pub)" \
    HostDNSLabelPrefix=${DNS_LABEL_PREFIX:?variable is empty} \
    caCert="$(cat ~/Downloads/Acmecert.crt)" \
    hostCert="$(cat ~/Downloads/home.labbuildr.com.crt)" \
    certKey="$(cat ~/Downloads/home.labbuildr.com.key)" \
    externalHostname=${EXTERNAL_HOSTNAME:?variable is empty}
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
    sshKeyData="$(cat ~/.ssh/id_rsa.pub)" \
    HostDNSLabelPrefix=${DNS_LABEL_PREFIX:?variable is empty} \
    caCert="$(cat ~/Downloads/Acmecert.crt)" \
    hostCert="$(cat ~/Downloads/home.labbuildr.com.crt)" \
    certKey="$(cat ~/Downloads/home.labbuildr.com.key)" \
    externalHostname=${EXTERNAL_HOSTNAME:?variable is empty}
    rootCA=${CERT} \
    container=${AZS_STORAGE_CONTAINER} \
    accountkey=${AZS_STORAGE_ACCOUNT_KEY} \
    accountname=${AZS_STORAGE_ACCOUNT_NAME} \
    azurestackdomain=${AZS_DOMAIN}
```

