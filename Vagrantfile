# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |v|
      v.memory = 2048
      v.cpus = 4
      v.customize ["modifyvm", :id, "--cpuexecutioncap", "70"]
      #v.gui = true # debug
  end

  config.vm.provision "ansible" do |a|
      a.playbook = "provisioning/playbook.yml"
  end

end
