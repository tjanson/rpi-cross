# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# This file tells Vagrant how to set up the virtual machine.
# It uses VirtualBox by default, and we'll stick to that.

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  # use an Ubuntu Trusty 64 base image
  config.vm.box = "ubuntu/trusty64"
  
  # bridge the VM into the host machine's network
  # you'll be prompted to select a network adapter at startup
  # choose whichever one you use for your home network
  config.vm.network "public_network"

  # customize these settings based on your machine
  # you'll probably want these values to be as high as possible
  # to speed up compilation, but of course you'll need to stay
  # within the limits of the host machine's hardware
  config.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 4
      v.customize ["modifyvm", :id, "--cpuexecutioncap", "70"]
      #v.gui = true # debug
  end

  # Vagrant will run this Ansible playbook upon setup, which is
  # where the interesting stuff happens - be sure to have a look
  config.vm.provision "ansible" do |a|
      a.playbook = "provisioning/playbook.yml"
  end

end
