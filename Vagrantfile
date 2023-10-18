# -*- mode: ruby -*-
# vi: set ft=ruby :
unless Vagrant.has_plugin?("vagrant-disksize")
  raise  Vagrant::Errors::VagrantError.new, "vagrant-disksize plugin is missing. Please install it using 'vagrant plugin install vagrant-disksize' and rerun 'vagrant up'"
end

Vagrant.configure("2") do |config|

  config.vm.box = "https://dl.rockylinux.org/vault/rocky/9.1/images/x86_64/Rocky-9-Vagrant-Vbox.latest.x86_64.box"
  config.vm.hostname = "site-deployment-vm"
  config.disksize.size = '30GB'
  #config.vm.disk :disk, size: "30GB", primary: true

  if Vagrant.has_plugin?("vagrant-hostmanager")
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
  end

  if Vagrant::Util::Platform.windows?
    #config.vbguest.installer_options = { allow_kernel_upgrade: true }
    config.vbguest.auto_update = false
    config.vm.synced_folder ".", "/vagrant", type: "virtualbox",
      mount_options: ["dmode=774,fmode=774"]   

    config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
        vb.cpus = 2
        vb.memory = 4096
    end
  elsif Vagrant::Util::Platform.darwin?
    config.vm.provider "virtualbox" do |vb|
        vb.cpus = 2
        vb.memory = 4096
    end
  else
    config.vm.synced_folder ".", "/vagrant", type: "nfs", nfs_version: 4

    config.vm.provider :libvirt do |libvirt|
        libvirt.cpus = 2
        libvirt.memory = 4096

        # Create a virtio channel for use by the qemu-guest agent (time sync, snapshotting, etc)
        libvirt.channel :type => 'unix', :target_name => 'org.qemu.guest_agent.0', :target_type => 'virtio'

        # Use system rather than user session
        # For this, your user must be in the libvirt group (Fedora/CentOS)
        libvirt.uri = 'qemu:///system'
      end
  end

  config.vm.provision "shell", inline: <<-SHELL

    # If present, set yum proxy to use default gateway Squid Proxy
    export GATEWAY=$(/sbin/ip route | awk '/default/ { print $3 }')

    timeout 5 bash -c "</dev/tcp/${GATEWAY}/3128"
    if [ $? -eq 0 ]
    then
       dnf config-manager --save --setopt=proxy=http://${GATEWAY}:3128 >/dev/null
    fi

    # Disable mirrorlist usage and use the default baseurl HTTP mirror. This
    # will make sure that the squid proxy effectively cache requested packages.

    sed -Ei 's/^mirrorlist=/#mirrorlist=/g'  /etc/yum.repos.d/rocky*.repo
    sed -Ei 's/^#baseurl=/baseurl=/g'        /etc/yum.repos.d/rocky*.repo

    # Update packages

    dnf update -y

    echo ", +" | sfdisk -N 5 /dev/sda --force
    partprobe
    sudo xfs_growfs /



  SHELL

end