# -*- mode: ruby -*- 
# vi: set ft=ruby : vsa
Vagrant.configure(2) do |config| 
  config.vm.box = "centos/7_2004_01" 
  config.vm.provider "virtualbox" do |v| 
  v.memory = 1024 
  v.cpus = 1 
  end 
  config.vm.define "nfss" do |nfss| 
    nfss.vm.network "private_network", ip: "192.168.56.120",  virtualbox__intnet: "net1" 
    nfss.vm.hostname = "nfsserv"
    nfss.vm.provision "shell", path: "nfs_server.sh"
  end 
  config.vm.define "nfsc" do |nfsc| 
    nfsc.vm.network "private_network", ip: "192.168.56.130",  virtualbox__intnet: "net1" 
    nfsc.vm.hostname = "nfscln"
    nfsc.vm.provision "shell", path: "nfs_client.sh" 	
  end 
end 
