# salt/security_baseline/minion_config.sls
configure-salt-minion:
  file.managed:
    - name: /etc/salt/minion.d/performance.conf
    - contents: |
        # Performance and connection optimizations
        return_retry_timer: 5
        return_retry_timer_max: 10
        auth_tries: 10
        auth_timeout: 10
        restart_on_error: True
        master_alive_interval: 10
        
        # Memory optimization
        recon_default: 1000
        recon_max: 60000
        recon_randomize: True
    - require:
      - pkg: salt-minion

restart-salt-minion:
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - file: configure-salt-minion