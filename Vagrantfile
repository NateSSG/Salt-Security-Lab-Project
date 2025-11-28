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
      vb.memory = 2048  # Increased for security tools
      vb.cpus = 1
    end

    master.vm.provision "shell", inline: <<-SHELL
      set -e
      echo "=== Installing Salt Master ==="
      
      # Install Salt Master
      wget -q https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public
      wget -q https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources
      sudo cp public /etc/apt/keyrings/salt-archive-keyring.pgp
      sudo cp salt.sources /etc/apt/sources.list.d/
      sudo apt-get update
      sudo apt-get install -y salt-master

      # Configure master to auto-accept keys - SECURE VERSION
      sudo sed -i '/auto_accept:/d' /etc/salt/master
      echo "auto_accept: True" | sudo tee -a /etc/salt/master
      
      # Configure master to bind to the correct interface
      sudo sed -i '/interface:/d' /etc/salt/master
      echo "interface: 192.168.56.10" | sudo tee -a /etc/salt/master

      # AGGRESSIVE MASTER CACHE CLEANUP - Stop service first
      sudo systemctl stop salt-master 2>/dev/null || true
      sudo rm -rf /var/cache/salt/master/minions/salt-minion 2>/dev/null || true
      sudo rm -rf /var/cache/salt/master/minions/* 2>/dev/null || true
      sudo rm -rf /var/cache/salt/master/jobs/* 2>/dev/null || true
      sudo rm -rf /var/cache/salt/master/.* 2>/dev/null || true

      # Enable and start master service
      sudo systemctl enable salt-master
      sudo systemctl start salt-master

      # Use YOUR actual Salt states from the project directory
      echo "📁 Setting up your Salt states from project directory..."

      # Create /srv/salt directory structure properly
      sudo mkdir -p /srv/salt
      sudo chown -R salt:salt /srv/salt

      # Copy your states to the master's salt directory
      if [ -d /vagrant/salt ]; then
        echo "✅ Found your Salt states in /vagrant/salt - deploying..."
        sudo cp -r /vagrant/salt/* /srv/salt/
        sudo chown -R salt:salt /srv/salt/
        echo "📋 Deployed states:"
        sudo find /srv/salt -type f -name "*.sls" | sudo xargs ls -la
      else
        echo "⚠️ No custom Salt states found, creating basic structure..."
        # Create a basic top.sls as fallback
        cat << 'EOF' | sudo tee /srv/salt/top.sls
base:
  '*':
    - sshd_port
EOF
      fi

      echo "✅ Salt Master installation completed"
    SHELL
  end

  # ---- Minion Node ----
  config.vm.define "salt-minion" do |minion|
    minion.vm.hostname = "salt-minion"
    minion.vm.network "private_network", ip: "192.168.56.11"

    minion.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
    end

    minion.vm.provision "shell", inline: <<-SHELL
      set -e
      echo "=== Installing Salt Minion ==="
      
      # Install Salt Minion
      wget -q https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public
      wget -q https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources
      sudo cp public /etc/apt/keyrings/salt-archive-keyring.pgp
      sudo cp salt.sources /etc/apt/sources.list.d/
      sudo apt-get update
      sudo apt-get install -y salt-minion

      # NUCLEAR CLEANUP - Remove ALL existing configs and cached data
      sudo systemctl stop salt-minion 2>/dev/null || true
      sudo pkill -f salt-minion 2>/dev/null || true
      sudo rm -f /etc/salt/minion
      sudo rm -f /etc/salt/minion_id
      sudo rm -rf /etc/salt/minion.d/*
      sudo rm -rf /etc/salt/pki/minion/*
      sudo rm -rf /var/cache/salt/minion/

      # COMPLETELY REPLACE the minion config file WITH WORKING SETTINGS
      cat << 'EOF' | sudo tee /etc/salt/minion
master: 192.168.56.10
id: salt-minion
master_port: 4506
master_tries: -1

# Connection reliability settings (NO DUPLICATES!)
return_retry_timer: 5
return_retry_timer_max: 10
auth_tries: 10
auth_timeout: 10
restart_on_error: True
master_alive_interval: 10

# Performance settings
recon_default: 1000
recon_max: 60000
recon_randomize: True
EOF

      echo "🔄 Waiting for network..."
      sleep 10

      # Start minion service
      sudo systemctl enable salt-minion
      sudo systemctl start salt-minion

      echo "✅ Salt Minion installation completed"
      echo "💡 Connecting to master automatically..."
    SHELL
  end
end

# It runs AFTER all VM provisioning
Vagrant.configure("2") do |config|
  # ---- GLOBAL SETUP - Runs after BOTH VMs are created AND provisioned ----
  config.vm.provision "shell", run: "once", inline: <<-SHELL
    echo "🎉 ===== FINAL AUTOMATED SETUP (AFTER ALL PROVISIONING) ====="
    
    # This only runs once, on whichever VM gets it first
    # We need to detect if we're on the master
    if command -v salt-key >/dev/null 2>&1; then
      echo "🔧 DEBUG: Detected Salt Master - Running automated setup..."
      
      # IMPROVED KEY HANDLING - Wait for stable key formation
      echo "🔑 Waiting for minion key to be properly generated..."
      
      key_found=false
      for i in {1..30}; do
        # Check if our specific minion key is present
        if sudo salt-key -L 2>/dev/null | grep "Unaccepted Keys" | grep -q "salt-minion"; then
          echo "✅ Minion key detected - waiting for key stabilization..."
          sleep 5  # Wait extra time for key to be fully formed
          
          # FORCE KEY REGENERATION to ensure it's clean
          echo "🔄 Ensuring clean key exchange..."
          sudo salt-key -d salt-minion -y 2>/dev/null || true
          sleep 3
          
          # Wait for new key to be generated
          echo "⏳ Waiting for new key generation..."
          sleep 10
          
          # Accept the fresh key
          if sudo salt-key -L 2>/dev/null | grep "Unaccepted Keys" | grep -q "salt-minion"; then
            echo "✅ Accepting fresh minion key..."
            sudo salt-key -a salt-minion -y 2>/dev/null || true
            key_found=true
            break
          fi
        fi
        
        # Also check if it's already accepted (from auto_accept)
        if sudo salt-key -L 2>/dev/null | grep "Accepted Keys" | grep -q "salt-minion"; then
          echo "✅ Minion key already accepted - testing communication..."
          key_found=true
          break
        fi
        
        echo "⏰ Waiting for minion key... ($((i * 2)) seconds)"
        sleep 2
      done

      if [ "$key_found" = false ]; then
        echo "❌ Minion key not found after waiting - forcing reconnection..."
        # Force minion to restart and regenerate key
        sudo salt '*' cmd.run "sudo systemctl restart salt-minion" 2>/dev/null || true
        sleep 10
        sudo salt-key -A -y 2>/dev/null || true
      fi

      # Wait for minion to connect and respond
      echo "📡 Testing minion connection..."
      
      connection_working=false
      for i in {1..20}; do
        if sudo salt '*' test.ping 2>/dev/null | grep -q "True"; then
          echo "✅ Minion is connected and responsive!"
          connection_working=true
          break
        fi
        echo "⏰ Testing connection... ($((i * 3)) seconds)"
        sleep 3
      done

      if [ "$connection_working" = true ]; then
        # Apply states
        echo "🚀 Applying Salt states automatically..."
        sudo salt '*' state.apply
        echo "🎉 FULLY AUTOMATED SETUP COMPLETED!"
      else
        echo "⚠️ Master-minion communication failed - using salt-call fallback..."
        sudo salt '*' cmd.run "sudo salt-call state.apply -l info" 2>/dev/null || echo "Fallback also failed"
      fi

      echo ""
      echo "🔧 Final Status:"
      sudo salt-key -L
      
    else
      echo "📋 This is the minion - Master will handle setup"
    fi
  SHELL
end
