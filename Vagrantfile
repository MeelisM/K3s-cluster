# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "master" do |master|
    master.vm.box = "ubuntu/focal64"
    master.vm.hostname = "k3s-master"
    master.vm.network "private_network", ip: "192.168.56.10"
    
    master.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    
    master.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y curl
      curl -sfL https://get.k3s.io | \
        INSTALL_K3S_EXEC="--node-ip 192.168.56.10 --bind-address 192.168.56.10 --flannel-iface=enp0s8 --write-kubeconfig-mode 644" \
        sh -
      echo "K3S_TOKEN=$(cat /var/lib/rancher/k3s/server/node-token)" > /vagrant/token
    SHELL

  end

  config.vm.define "agent" do |agent|
    agent.vm.box = "ubuntu/focal64"
    agent.vm.hostname = "k3s-agent"
    agent.vm.network "private_network", ip: "192.168.56.11"
    
    agent.vm.provider "virtualbox" do |vb|
      vb.memory = "2048"
      vb.cpus = 2
    end
    
    agent.vm.provision "shell", inline: <<-SHELL
      apt-get update
      apt-get install -y curl
      while [ ! -f /vagrant/token ]; do
        echo "Waiting for K3s master token..."
        sleep 5
      done
      
      source /vagrant/token
      curl -sfL https://get.k3s.io | \
        INSTALL_K3S_EXEC="--node-ip 192.168.56.11 --flannel-iface=enp0s8" \
        K3S_URL=https://192.168.56.10:6443 \
        K3S_TOKEN=${K3S_TOKEN} sh -
    SHELL
  end
end