# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Base box
  config.vm.box = "debian/bookworm64"

  # ---- Master Node ----
  config.vm.define "salt-master" do |master|
    master.vm.hostname = "salt-master"
    master.vm.network "private_network", ip: "192.168.56.10"

    master.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end

    master.vm.provision "shell", inline: <<-SHELL
      # Install Salt Master and Minion
      wget https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public
      wget https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources
      sudo cp public /etc/apt/keyrings/salt-archive-keyring.pgp
      sudo cp salt.sources /etc/apt/sources.list.d/
      sudo apt-get update
      sudo apt-get install -y salt-master salt-minion

      # Enable master and minion services
      sudo systemctl enable salt-master
      sudo systemctl start salt-master
      sudo systemctl enable salt-minion
      sudo systemctl start salt-minion

      # Wait a few seconds for minion to register
      sleep 10

      # Automatically accept all minion keys
      sudo salt-key -A -y

      # Apply Salt states
      sudo salt '*' state.apply
    SHELL
  end

  # ---- Minion Node ----
  config.vm.define "salt-minion" do |minion|
    minion.vm.hostname = "salt-minion"
    minion.vm.network "private_network", ip: "192.168.56.11"

    minion.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end

    minion.vm.provision "shell", inline: <<-SHELL
      # Install Salt Minion
      wget https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public
      wget https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources
      sudo cp public /etc/apt/keyrings/salt-archive-keyring.pgp
      sudo cp salt.sources /etc/apt/sources.list.d/
      sudo apt-get update
      sudo apt-get install -y salt-minion

      # Point minion to master
      echo "master: 192.168.56.10" | sudo tee /etc/salt/minion

      # Enable and restart minion service
      sudo systemctl enable salt-minion
      sudo systemctl restart salt-minion
    SHELL
  end
end
