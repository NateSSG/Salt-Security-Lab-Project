# 🛡️ Mini SIEM Saltstack Security Lab | Created By: Nathaniel Ssendagire & Janne Sormunen

## 🔧 Key Technical Achievements
- **Solved master-minion communication issues** with connection reliability settings
- **Replaced heavy Filebeat** with lightweight rsyslog forwarding
- **Optimized package selection** for stable SaltStack deployment
- **Proven idempotent infrastructure** - states deploy reliably every time


## 🎯 Educational Value

Demonstrates modern infrastructure as code principles:
- Centralized configuration management
- Idempotent state deployment
- Automated security tooling
- SaltStack master-minion architecture

## 🚀 Quick Start
    # Deploy the entire lab
    vagrant destroy -f && vagrant up
    
    # SSH into machines
    vagrant ssh salt-master
    vagrant ssh salt-minion

    # Test basic master-minion communication
    vagrant ssh salt-master -c "sudo salt '*' test.ping"
    vagrant ssh salt-master -c "sudo salt '*' cmd.run 'echo hello'"

    # Test full state application
    vagrant ssh salt-master -c "sudo salt --timeout=180 '*' state.apply"

    # Verify SIEM services are running
    vagrant ssh salt-master -c "sudo salt '*' service.status fail2ban"
    vagrant ssh salt-master -c "sudo salt '*' cmd.run 'ufw status'"
    vagrant ssh salt-master -c "sudo salt '*' service.status auditd"
    
    # Test log collection
    vagrant ssh salt-minion -c "sudo /usr/local/bin/siem-log-monitor.sh"

    
    
## 🔍 Security Monitoring Commands
    # Quick health check (run on salt-master)
    sudo salt '*' state.apply test=true
    sudo salt '*' test.ping
    
    # Comprehensive status check
    echo "🛡️ SECURITY STATUS:" && \
    sudo salt '*' cmd.run "systemctl is-active fail2ban && echo '✅ Fail2ban'" && \
    sudo salt '*' cmd.run "systemctl is-active ufw && echo '✅ UFW'" && \
    sudo salt '*' cmd.run "systemctl is-active filebeat && echo '✅ Filebeat'" && \
    sudo salt '*' cmd.run "ufw status | head -5"

## 📊 Log Collection & Monitoring

    # Check Filebeat logs (on salt-minion)
    sudo tail -f /tmp/filebeat/filebeat.log-*.ndjson
    
    # Check Filebeat service
    sudo systemctl status filebeat
    sudo journalctl -u filebeat -f
    
    # View collected log files
    sudo ls -la /tmp/filebeat/
    sudo wc -l /tmp/filebeat/filebeat.log-*.ndjson

## 🔒 Intrusion Detection (Fail2ban)

    # Check Fail2ban status
    sudo fail2ban-client status
    sudo fail2ban-client status sshd
    
    # Check banned IPs
    sudo fail2ban-client status sshd | grep "Banned IP"
    
    # Unban an IP (if needed)
    sudo fail2ban-client set sshd unbanip IP_ADDRESS

🌐 Firewall Status (UFW)

    # Check firewall rules
    sudo ufw status
    sudo ufw status numbered
    
    # Check active connections
    sudo netstat -tulpn | grep -E ':(22|2222|4505|4506)'

## 🔍 Security Scanning Tools

    # Run security audit
    sudo lynis audit system --quick
    sudo lynis audit system --tests-from-group malware
    
    # Rootkit scan
    sudo rkhunter --check --sk
    
    # File integrity check
    sudo aide --check

## 📈 System Monitoring

    # Real-time system monitoring
    sudo htop
    sudo iotop
    
    # System statistics
    sudo iostat -x 1
    sudo vmstat 1
    
    # Log analysis
    sudo logwatch --range today

## 🧪 Testing Security Features

### Test Fail2ban Protection

    # From another terminal, try failed SSH logins:
    ssh vagrant@192.168.56.11  # Use wrong password 3+ times
    
    # Then check if IP gets banned:
    sudo fail2ban-client status sshd

### Test Log Collection

    # Generate some log activity
    sudo systemctl restart ssh
    sudo useradd testuser 2>/dev/null || true
    
    # Check if Filebeat captured it
    sudo tail -f /var/log/siem-central.log | grep -E "(ssh|useradd)"

## 🗂️ File Locations

### Configuration Files

- Salt States: /srv/salt/ on salt-master

- Fail2ban Config: /etc/fail2ban/jail.local

- Rsyslog Config: /etc/rsyslog.conf

- SSH Config: /etc/ssh/sshd_config

- Firewall Rules: sudo ufw status

### Log Files

- Centralized Logs: /var/log/siem-central.log

- Fail2ban Logs: /var/log/fail2ban.log

- System Logs: /var/log/auth.log, /var/log/syslog

- Security Scans: /var/log/lynis.log, /var/log/rkhunter.log

## Troubleshooting

### Services Not Starting? 

    # Restart services
    sudo systemctl restart fail2ban
    sudo systemctl restart filebeat
    sudo systemctl restart ufw
    
    # Check logs
    sudo journalctl -u fail2ban -f
    sudo journalctl -u filebeat -f
    
### Salt Communication Issues
    # On salt-master
    sudo salt '*' test.ping
    sudo salt-key -L
    sudo systemctl restart salt-master
    
    # On salt-minion  
    sudo systemctl restart salt-minion

## Filebeat Not Collecting Logs

    # Check configuration
    sudo filebeat test config
    sudo filebeat test output
    
    # Manual log check
    sudo tail -f /var/log/auth.log
    sudo tail -f /var/log/syslog

## 📋 Security Tools Inventory

| Tool        | Purpose                     | Status Command                     |
|-------------|------------------------------|------------------------------------|
| Fail2ban    | SSH brute force protection   | sudo systemctl status fail2ban     |
| UFW         | Network firewall             | sudo ufw status                    |
| Rsyslog     | Centralized log collection   | sudo systemctl status rsyslog      |
| Lynis       | Security auditing            | sudo lynis show version            |
| RKHunter    | Rootkit detection            | sudo rkhunter --versioncheck       |
| AIDE        | File integrity               | sudo aide --version                |
| Auditd      | System auditing              | sudo systemctl status auditd       |
| DebSums     | Package integrity            | sudo debsums --version             |
| htop/iotop  | System monitoring            | sudo htop                          |



## 🚨 Emergency Commands

    # Block an IP immediately
    sudo ufw deny from IP_ADDRESS
    
    # Stop all services
    sudo systemctl stop fail2ban filebeat ufw
    
    # Reset entire lab
    vagrant destroy -f && vagrant up

