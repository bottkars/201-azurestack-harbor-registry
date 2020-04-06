#!/usr/bin/env bash
function retryop()
{
  retry=0
  max_retries=$2
  interval=$3
  while [ ${retry} -lt ${max_retries} ]; do
    echo "Operation: $1, Retry #${retry}"
    eval $1
    if [ $? -eq 0 ]; then
      echo "Successful"
      break
    else
      let retry=retry+1
      echo "Sleep $interval seconds, then retry..."
      sleep $interval
    fi
  done
  if [ ${retry} -eq ${max_retries} ]; then
    echo "Operation failed: $1"
    exit 1
  fi
}

START_BASE_DEPLOY_TIME=$(date)
echo ${START_BASE_DEPLOY_TIME} starting base deployment
echo "Installing jq"
retryop "apt update && apt install -y jq" 10 30

function get_setting() {
  key=$1
  local value=$(echo $settings | jq ".$key" -r)
  echo "${value}" ## ( use "${VAR}" to retain spaces, KB)
}
custom_data_file="/var/lib/cloud/instance/user-data.txt"
settings=$(cat ${custom_data_file})



HARBOR_USERNAME=$(get_setting HARBOR_USERNAME)
ADMIN_USERNAME=$(get_setting ADMIN_USERNAME)
FQDN=$(get_setting FQDN)
EXTERNAL_HOSTNAME=$(get_setting EXTERNAL_HOSTNAME)

SSH_PUBLIC_KEY=$(get_setting SSH_PUBLIC_KEY)
AZS_CA=$(get_setting AZS_CA)
AZS_STORAGE_CONTAINER=$(get_setting AZS_STORAGE_CONTAINER)
AZS_STORAGE_ACCOUNT_KEY=$(get_setting AZS_STORAGE_ACCOUNT_KEY)
AZS_STORAGE_ACCOUNT_NAME=$(get_setting AZS_STORAGE_ACCOUNT_NAME)
AZS_BASE_DOMAIN=$(get_setting AZS_BASE_DOMAIN)
DOWNLOAD_DIR="/datadisks/disk1"
CA_CERT=$(get_setting CA_CERT)
HOST_CERT=$(get_setting HOST_CERT)
CERT_KEY=$(get_setting CERT_KEY)

HOME_DIR="/home/${ADMIN_USERNAME}"
LOG_DIR="${HOME_DIR}/conductor/logs"
SCRIPT_DIR="${HOME_DIR}/conductor/scripts"
LOG_DIR="${HOME_DIR}/conductor/logs"
ENV_DIR="${HOME_DIR}/conductor/env"
TEMPLATE_DIR="${HOME_DIR}/conductor/templates"

sudo -S -u ${ADMIN_USERNAME} mkdir -p ${TEMPLATE_DIR}
sudo -S -u ${ADMIN_USERNAME} mkdir -p ${SCRIPT_DIR}
sudo -S -u ${ADMIN_USERNAME} mkdir -p ${ENV_DIR}
sudo -S -u ${ADMIN_USERNAME} mkdir -p ${LOG_DIR}

cp *.sh ${SCRIPT_DIR}
chown ${ADMIN_USERNAME}.${ADMIN_USERNAME} ${SCRIPT_DIR}/*.sh
chmod 755 ${SCRIPT_DIR}/*.sh
chmod +X ${SCRIPT_DIR}/*.sh

cp *.yaml ${TEMPLATE_DIR}
chown ${ADMIN_USERNAME}.${ADMIN_USERNAME} ${TEMPLATE_DIR}/*.yaml
chmod 755 ${TEMPLATE_DIR}/*.yaml

cp *.env ${ENV_DIR}
chown ${ADMIN_USERNAME}.${ADMIN_USERNAME} ${ENV_DIR}/*.env
chmod 755 ${ENV_DIR}/*.env

${SCRIPT_DIR}/vm-disk-utils-0.1.sh

chown ${ADMIN_USERNAME}.${ADMIN_USERNAME} ${DOWNLOAD_DIR}
chmod -R 755 ${DOWNLOAD_DIR}

if  [ ! -z ${EXTERNAL_HOSTNAME} ] && \
[ ${EXTERNAL_HOSTNAME} != "null" ]; then
  FQDN=${EXTERNAL_HOSTNAME}
fi


$(cat <<-EOF > ${HOME_DIR}/.env.sh
#!/usr/bin/env bash
FQDN="${FQDN}"
LOCATION="${LOCATION}"
HOME_DIR="${HOME_DIR}"
HARBOR_USERNAME="${HARBOR_USERNAME}"
ADMIN_USERNAME="${ADMIN_USERNAME}"
DOWNLOAD_DIR="${DOWNLOAD_DIR}"
LOG_DIR=${LOG_DIR}
ENV_DIR=${ENV_DIR}
SCRIPT_DIR=${SCRIPT_DIR}
TEMPLATE_DIR=${TEMPLATE_DIR}
AZS_CA="${AZS_CA}"
AZS_STORAGE_CONTAINER=${AZS_STORAGE_CONTAINER}
AZS_STORAGE_ACCOUNT_KEY="${AZS_STORAGE_ACCOUNT_KEY}"
AZS_STORAGE_ACCOUNT_NAME=${AZS_STORAGE_ACCOUNT_NAME}
AZS_BASE_DOMAIN=${AZS_BASE_DOMAIN}
CA_CERT="$(get_setting CA_CERT)"
HOST_CERT="$(get_setting HOST_CERT)"
CERT_KEY="$(get_setting CERT_KEY)"
FQDN="${FQDN}"
EOF
)

chmod 600 ${HOME_DIR}/.env.sh
chown ${ADMIN_USERNAME}.${ADMIN_USERNAME} ${HOME_DIR}/.env.sh

retryop "sudo apt -y install apt-transport-https lsb-release software-properties-common" 10 30

sudo apt-get update

retryop "sudo apt -y install unzip" 10 30

cd ${HOME_DIR}

${SCRIPT_DIR}/deploy_docker.sh ${HOME_DIR} 

END_BASE_DEPLOY_TIME=$(date)
echo ${END_BASE_DEPLOY_TIME} end base deployment


echo "Base install finished, now initializing harbor
for install status information, run 'tail -f ${LOG_DIR}/deploy_harbor.sh.*.log'"

su ${ADMIN_USERNAME}  -c "nohup ${SCRIPT_DIR}/deploy_harbor.sh -h ${HOME_DIR} >/dev/null 2>&1 &"