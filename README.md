# DEPLOY-SCRIPTS

# Local Python Virtual Environment

Create virtual environement

```
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

Reset virtual environment

```
deactivate
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.in
pip freeze > requirements.txt
```

# Vagrant

With Fedora NFS and Squid services will work only after doing this:
```
firewall-cmd --permanent --zone=libvirt --add-service=nfs
firewall-cmd --permanent --zone=libvirt --add-service=squid
firewall-cmd --reload
```

Start and provision:
```
vagrant up
```

SSH to virtual machine:
```
vagrant ssh
```

Destroy virtual machine:
```
vagrant destroy
```

# Ansible

Launch from this directory:

```
export ANSIBLE_CONFIG=ansible.vagrant.cfg
ansible-playbook -i site-deployment-vm, playbooks/vagrant.yml
```

