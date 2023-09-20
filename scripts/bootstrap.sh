#!/usr/bin/env bash
#
# Locally test this script in Vagrant:
#    host$ vagrant rsync
#    guest# 
#export CODA_USE_VAGRANT=true
#    guest# 
#rm -rf /opt/coda #&& bash /vagrant/scripts/bootstrap.sh
#
################################################################################
#### GENERAL PARAMETERS AND SETTINGS
################################################################################

# TARGET DIRECTORIES

CODA_BASE_DIR=/opt/coda
CODA_ANSIBLE_VENV_DIR=${CODA_BASE_DIR}/venv-ansible

# FORCE TO USE BOOTSTRAP.SH AND BOOTSTRAP.YML FROM VAGRANT

CODA_USE_VAGRANT=${CODA_USE_VAGRANT:-false}
CODA_ANSIBLE_VENV_REQUIREMENTS_FILE=/vagrant/requirements.txt
CODA_ANSIBLE_BOOTSTRAP_PLAYBOOK_FILE=/vagrant/playbooks/misc/bootstrap.yml


# ANSIBLE VENV REQUIREMENTS FILE

CODA_ANSIBLE_BASE_URL=https://raw.githubusercontent.com/coda-platform/site-deployer-ansible/main
CODA_ANSIBLE_VENV_REQUIREMENTS_URL=${CODA_ANSIBLE_BASE_URL}/requirements.txt
CODA_ANSIBLE_BOOTSTRAP_PLAYBOOK_URL=${CODA_ANSIBLE_BASE_URL}/playbooks/misc/bootstrap.yml

# DEPLOYMENT USER PUBLIC KEY URL

CODA_DEPLOYMENT_USER_PUB_KEY_URL=https://raw.githubusercontent.com/CODA-19/deploy-scripts/master/ansible/keys/id_rsa.deployment.pub

#### DEFINE COLORS

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)

#### CHECK IF RUNNING AS ROOT

if [ "$EUID" -ne 0 ]
then
  echo "${BOLD}${RED}!!!! PLEASE RUN AS ROOT OR USE SUDO !!!!${NORMAL}"
  exit
fi

################################################################################
#### INSTALL REQUIRED SYSTEM PACKAGES
################################################################################

echo "${BOLD}${YELLOW}*** INSTALLING REQUIRED SYSTEM PACKAGES ***${NORMAL}"

# COMMON PACKAGES

dnf install -y curl \
               wget \
               git \
               python3 \
               python3-pip \
               libselinux-python3 \
               util-linux \
               nano



################################################################################
#### ADD DEPLOYMENT USER
################################################################################

echo "${BOLD}${YELLOW}*** CREATING DEPLOYMENT USER ***${NORMAL}"

userdel --remove coda-deployment 2>/dev/null
useradd coda-deployment --groups wheel --password '$6$mayq9jenCSAnecbp$z64XGUJG3e9Gyh8rC6HIAS62ykwr4Tv0glAC1zjVVhq73S3bulIQXNuwRFc8QL.C3pUn2OOtKjComEViWGPLJ/' 2>/dev/null

# CREATE .SSH FOLDER AND PUBLIC KEY

mkdir -p ~coda-deployment/.ssh
curl -so ~coda-deployment/.ssh/authorized_keys ${CODA_DEPLOYMENT_USER_PUB_KEY_URL}

# SET OWNERSHIP AND PRIVILEGES

chown -R coda-deployment:coda-deployment ~coda-deployment/.ssh

chmod 0700 ~coda-deployment/.ssh
chmod 0644 ~coda-deployment/.ssh/authorized_keys

################################################################################
#### CLONE LOCALLY
################################################################################

# echo "${BOLD}${YELLOW}*** Cloning deployment scripts ***${NORMAL}"
#
# FORCE_GIT_SOURCES=false
#
# mkdir -p ${CODA_BASE_DIR}
# if [[ -d "/vagrant" && ${FORCE_GIT_SOURCES} = false ]]; then
#   echo "${YELLOW}Using local /vagrant folder...${NORMAL}"
#   ln -sf /vagrant ${CODA_BASE_DIR}/deploy-scripts-pull
# else
#   echo "${YELLOW}Cloning from github.com...${NORMAL}"
#   git clone https://github.com/coda-platform/site-deployer-ansible.git ${CODA_BASE_DIR}/deploy-scripts-pull/
# fi

################################################################################
#### CREATE VENV AND INSTALL REQUIREMENTS
################################################################################

#### CREATING MINIMAL VENV, SOURCE IT AND UPDATE PIP

echo "${BOLD}${YELLOW}*** CREATING ANSIBLE VIRTUAL ENVIRONMENT ***${NORMAL}"
echo "${YELLOW}Dst:${NORMAL} ${CODA_ANSIBLE_VENV_DIR}"

mkdir -p ${CODA_ANSIBLE_VENV_DIR}
python3 -m venv ${CODA_ANSIBLE_VENV_DIR}
source ${CODA_ANSIBLE_VENV_DIR}/bin/activate
pip install --upgrade pip

#### FETCH AND INSTALL REQUIREMENTS

echo "${BOLD}${YELLOW}*** INSTALLING REQUIREMENTS ***${NORMAL}"

if [[ -d "/vagrant" && ${CODA_USE_VAGRANT} = true ]]; then
  echo "${YELLOW}Src:${NORMAL} ${CODA_ANSIBLE_VENV_REQUIREMENTS_FILE}"

  REQUIREMENTS=${CODA_ANSIBLE_VENV_REQUIREMENTS_FILE}
else
  REQUIREMENTS=$( mktemp --tmpdir=/tmp requirements-XXXXX.txt )
  echo "${YELLOW}Src:${NORMAL} ${CODA_ANSIBLE_VENV_REQUIREMENTS_URL}"
  echo "${YELLOW}Dst:${NORMAL} ${REQUIREMENTS}"

  curl -so ${REQUIREMENTS} ${CODA_ANSIBLE_VENV_REQUIREMENTS_URL}
fi

pip install --no-warn-script-location -r ${REQUIREMENTS}

################################################################################
#### CREATE VENV ACTIVATORS AND HELPERS
################################################################################

echo "${BOLD}${YELLOW}*** CREATING ANSIBLE VIRTUAL ENVIRONMENT ACTIVATORS ***${NORMAL}"

cat << EOT > /etc/profile.d/env-ansible.sh
function env-ansible {
  source ${CODA_ANSIBLE_VENV_DIR}/bin/activate
}
EOT

chmod a+r /etc/profile.d/env-ansible.sh

################################################################################
#### CREATE BASIC DIRS AND FILES
################################################################################

# Just to get out some warning messages in bootstrap playbook.
mkdir -p /etc/ansible/facts.d/
echo "<dummy>" > /etc/ansible/vault.pass
touch /etc/ansible/facts.d/coda.fact

################################################################################
#### BOOTSTRAP PLAYBOOK
################################################################################

if [[ -z "$CODA_SANDBOX" ]]
then

  echo "${BOLD}${YELLOW}*** RUNNING BOOTSTRAP PLAYBOOK ***${NORMAL}"

  #### LAUNCH PLAYBOOK - FROM FETCHED FILE

  if [[ -d "/vagrant" && ${CODA_USE_VAGRANT} = true ]]; then
    echo "${YELLOW}Src:${NORMAL} ${CODA_ANSIBLE_BOOTSTRAP_PLAYBOOK_FILE}"

    PLAYBOOK=${CODA_ANSIBLE_BOOTSTRAP_PLAYBOOK_FILE}
  else
    PLAYBOOK=$( mktemp --tmpdir=/tmp bootstrap-XXXXX.yml )
    echo "${YELLOW}Src:${NORMAL} ${CODA_ANSIBLE_BOOTSTRAP_PLAYBOOK_URL}"
    echo "${YELLOW}Dst:${NORMAL} ${PLAYBOOK}"

    curl -so ${PLAYBOOK} ${CODA_ANSIBLE_BOOTSTRAP_PLAYBOOK_URL}
  fi

  echo
  echo "${BOLD}${YELLOW}*********************************************${NORMAL}"
  echo "${BOLD}${YELLOW}*** PLEASE ANSWER THE FOLLOWING QUESTIONS ***${NORMAL}"
  echo "${BOLD}${YELLOW}*********************************************${NORMAL}"
  echo

  ansible-playbook \
    --inventory localhost, \
    ${PLAYBOOK}

fi
