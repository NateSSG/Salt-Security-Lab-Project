# Install OpenSSH server
openssh-server:
  pkg.installed

# Deploy our SSH configuration
/etc/ssh/sshd_config:
  file.managed:
    - source: salt://sshd_port/sshd_config
    - user: root
    - group: root
    - mode: 600
    - backup: True

# Ensure SSH service is running and reload if config changes
sshd:
  service.running:
    - enable: True
    - watch:
      - file: /etc/ssh/sshd_config
