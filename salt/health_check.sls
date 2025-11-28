# health_check.sls - Auto-recovery for common issues

clean_stuck_processes:
  cmd.run:
    - name: |
        pkill -f "wget.*filebeat" || true
        pkill -f "salt-minion.*MultiMinion" || true
    - onlyif: "pgrep -f 'wget.*filebeat' || pgrep -f 'salt-minion.*MultiMinion'"

clear_salt_cache:
  cmd.run:
    - name: |
        rm -rf /var/cache/salt/minion/* || true
        systemctl reset-failed salt-minion || true
    - onlyif: "test -d /var/cache/salt/minion"

restart_salt_minion_if_needed:
  service.running:
    - name: salt-minion
    - enable: True
    - watch:
      - cmd: clean_stuck_processes
      - cmd: clear_salt_cache
