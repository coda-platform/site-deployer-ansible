# Ansible scripts for site node deployment

## Local Python virtual environment

**Create virtual environement**

```
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

**Reset virtual environment**

```
deactivate
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.in
pip freeze > requirements.txt
```

## Setup Vagrant

**Mac OS X**

Install Vagrant:

- First, install Vagrant: `brew install vagrant`
- Second, install a box provider. On Mac, VirtualBox is easiest. For Apple Silicon (M1/M2), must use the [latest development build](https://www.virtualbox.org/wiki/Testbuilds) - use the build called `macOS/ARM64 BETA`

## Setup Firewall

**Fedora**

With Fedora, NFS and Squid services will work only after doing this:
```
firewall-cmd --permanent --zone=libvirt --add-service=nfs
firewall-cmd --permanent --zone=libvirt --add-service=squid
firewall-cmd --reload
```

## Launch Vagrant

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

## Launch Ansible

Launch playbook from this directory:

```
export ANSIBLE_CONFIG=ansible.vagrant.cfg
ansible-playbook -i site-deployment-vm, playbooks/vagrant.yml
```

