# security_baseline/init.sls

# Install and configure fail2ban
fail2ban:
  pkg.installed: []
  service.running:
    - enable: True
    - watch:
      - file: /etc/fail2ban/jail.local

/etc/fail2ban/jail.local:
  file.managed:
    - source: salt://security_baseline/fail2ban_local.conf
    - user: root
    - group: root
    - mode: 644

# Basic firewall setup
ufw:
  pkg.installed: []
  service.running:
    - enable: True
    - watch:
      - cmd: ufw-init

ufw-init:
  cmd.run:
    - name: |
        ufw --force reset
        ufw allow 22
        ufw allow 2222
        ufw allow 4505
        ufw allow 4506
        ufw --force enable
    - unless: "ufw status | grep -q 'Status: active'"

# Common security packages
security_packages:
  pkg.installed:
    - pkgs:
      - auditd
      - aide
      - rkhunter
      - chkrootkit

# Enable auditd
auditd:
  service.running:
    - enable: True
