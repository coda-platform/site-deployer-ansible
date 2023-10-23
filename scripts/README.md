###SCRIPT bootstrap
#This script is to be run by the root user on the site-vm after initial vm generation.

#Vagrant local use for development/testing
#In order to run the bootstrap script in vagrant uncomment the following lines in /vagrant/scripts/bootstrap.sh script before running

####################################################################################################################
export CODA_USE_VAGRANT=true

echo "${BOLD}${YELLOW}*** Cloning deployment scripts ***${NORMAL}"

 FORCE_GIT_SOURCES=false

 mkdir -p ${CODA_BASE_DIR}
 if [[ -d "/vagrant" && ${FORCE_GIT_SOURCES} = false ]]; then
   echo "${YELLOW}Using local /vagrant folder...${NORMAL}"
   ln -sf /vagrant ${CODA_BASE_DIR}/deploy-scripts-pull
 else
   echo "${YELLOW}Cloning from github.com...${NORMAL}"
   git clone https://github.com/coda-platform/site-deployer-ansible.git ${CODA_BASE_DIR}/deploy-scripts-pull/
 fi
#####################################################################################################################

#After uncommenting run the bootstrap script and answer questions
bash /vagrant/scripts/bootstrap.sh

###Activate environment
source /opt/coda/venv-ansible/bin/activate

###Run playbook
ansible-playbook playbooks/localhost.yml