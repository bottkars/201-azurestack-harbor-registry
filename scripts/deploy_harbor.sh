#!/usr/bin/env bash
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -h|--HOME)
    HOME_DIR="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

if  [ -z ${HOME_DIR} ] ; then
 echo "Please specify HOME DIR -h|--HOME"
 exit 1
fi 

cd ${HOME_DIR}
source ${HOME_DIR}/.env.sh
MYSELF=$(basename $0)
mkdir -p ${LOG_DIR}
exec &> >(tee -a "${LOG_DIR}/${MYSELF}.$(date '+%Y-%m-%d-%H').log")
exec 2>&1

### certificate stuff

if  [ -z ${HOST_CERT} ] ; then
  echo "No host Cert presented need to generates selfsigned certs for $FQDN"
  ${SCRIPT_DIR}/create_self_certs.sh
else
  echo "${CA_CERT}" > ${FQDN}.ca.crt
  echo "${HOST_CERT}" > ${FQDN}.host.crt
  echo "${CERT_KEY}" > ${FQDN}.key
fi  




# TAG=$(curl -s https://api.github.com/repos/goharbor/harbor/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
TAG="v2.1.1" # shall we include a logig if tag is an RC and has no online installer ?
URI="https://github.com/goharbor/harbor/releases/download/${TAG}/harbor-online-installer-${TAG}.tgz"
wget $URI
tar xzfv harbor-online-installer-${TAG}.tgz
echo "editing values in harbor.yml"
if [[ -f ./harbor/harbor.yml.tmpl ]]
    then 
    cp ./harbor/harbor.yml.tmpl ./harbor/harbor.yml
    fi
sed "s/^hostname: .*/hostname: ${FQDN}/g" -i ./harbor/harbor.yml
sed "s/^  certificate: .*/  certificate: ${HOME_DIR//\//\\/}\/${FQDN}.host.crt/g" -i ./harbor/harbor.yml
sed "s/^  private_key: .*/  private_key: ${HOME_DIR//\//\\/}\/${FQDN}.key/g" -i ./harbor/harbor.yml
sed "s/^data_volume: \/data/data_volume: \/datadisks\/disk1/g" -i ./harbor/harbor.yml

if [ -s "${FQDN}.ca.crt" ] ; then
    sudo mkdir -p /etc/docker/certs.d/${FQDN}/
    sudo cp  ${HOME_DIR}/${FQDN}.ca.crt /etc/docker/certs.d/${FQDN}/ca.crt
    sudo systemctl restart docker    
fi
#cat <<EOF >> ./harbor/harbor.yml
#storage_service:
#  ca_bundle: "${AZS_CA}"
#  azure:
#    accountname: ${AZS_STORAGE_ACCOUNT_NAME}
#    accountkey: ${AZS_STORAGE_ACCOUNT_KEY}
#    container: ${AZS_STORAGE_CONTAINER}
#    realm: ${AZS_BASE_DOMAIN}
# EOF

cd ./harbor
sudo ./install.sh
