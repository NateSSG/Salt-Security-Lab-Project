# log_collection/init.sls - RSYSLOG FORWARDING VERSION

# Configure rsyslog for centralized log collection
configure_rsyslog_forwarding:
  file.append:
    - name: /etc/rsyslog.conf
    - text: |
        # SIEM Centralized Log Collection
        # All system logs aggregated to centralized location
        *.* /var/log/siem-central.log
        # In production: *.* @192.168.56.10:514
    - unless: "grep -q 'siem-central.log' /etc/rsyslog.conf"

restart_rsyslog:
  service.running:
    - name: rsyslog
    - watch:
      - file: configure_rsyslog_forwarding

# Install basic log analysis tools
install_log_tools:
  pkg.installed:
    - pkgs:
      - logwatch
      - sysstat
      - htop
      - iotop

# Create SIEM log monitoring script
create_siem_monitor:
  file.managed:
    - name: /usr/local/bin/siem-log-monitor.sh
    - contents: |
        #!/bin/bash
        # SIEM Log Monitor
        echo "=== SIEM Log Collection Status ==="
        echo "Central log file: /var/log/siem-central.log"
        echo "Log sources:"
        echo "- System logs"
        echo "- Authentication events" 
        echo "- Security events"
        echo "- Application logs"
        echo ""
        echo "Recent log entries:"
        tail -5 /var/log/siem-central.log 2>/dev/null || echo "No logs yet - system will populate automatically"
    - mode: 755

# Test the log collection
test_log_collection:
  cmd.run:
    - name: |
        echo "$(date): SIEM log collection configured via SaltStack" >> /var/log/siem-central.log
        /usr/local/bin/siem-log-monitor.sh
    - creates: /var/log/siem-central.log