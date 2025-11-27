# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Base box
  config.vm.box = "debian/bookworm64"   # or "debian/trixie64" if using Trixie

  # ---- Master Node ----
  config.vm.define "salt-master" do |master|
    master.vm.hostname = "salt-master"
    master.vm.network "private_network", ip: "192.168.56.10"

    master.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
    end

    # Provision Salt Master
    master.vm.provision "shell", inline: <<-SHELL
      # Install Salt
      wget https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public
      wget https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources
      sudo cp public /etc/apt/keyrings/salt-archive-keyring.pgp
      sudo cp salt.sources /etc/apt/sources.list.d/
      sudo apt-get update
      sudo apt-get install -y salt-master salt-minion
      sudo systemctl enable salt-master
      sudo systemctl start salt-master

      # Apply Salt states from project folder
      sudo salt-call --local --file-root=/vagrant/salt state.apply
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

    # Provision Salt Minion
    minion.vm.provision "shell", inline: <<-SHELL
      # Install Salt
      wget https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public
      wget https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources
      sudo cp public /etc/apt/keyrings/salt-archive-keyring.pgp
      sudo cp salt.sources /etc/apt/sources.list.d/
      sudo apt-get update
      sudo apt-get install -y salt-minion

      # Point minion to master
      echo "master: 192.168.56.10" | sudo tee /etc/salt/minion
      sudo systemctl enable salt-minion
      sudo systemctl restart salt-minion

      # Apply Salt states from project folder
      sudo salt-call --local --file-root=/vagrant/salt state.apply
    SHELL
  end
end
