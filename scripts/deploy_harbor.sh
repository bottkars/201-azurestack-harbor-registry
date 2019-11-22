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

TAG=$(curl -s https://api.github.com/repos/goharbor/harbor/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
URI="https://github.com/goharbor/harbor/releases/download/${TAG}/harbor-online-installer-${TAG}.tgz"
wget $URI
tar xzfv harbor-online-installer-${TAG}.tgz
sed "s/^hostname: .*/hostname: ${FQDN}/g" -i ./harbor/harbor.yml
sed "s/^data_volume: \/data/data_volume: \/datadisks\/disk1/g" -i ./harbor/harbor.yml


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




