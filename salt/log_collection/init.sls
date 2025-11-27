# log_collection/init.sls - CLEAN VERSION

# Install wget if not present
install_wget:
  pkg.installed:
    - name: wget

# Download Filebeat package directly (bypass apt repositories)
download_filebeat_package:
  cmd.run:
    - name: wget -qO /tmp/filebeat.deb https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-8.11.0-amd64.deb
    - creates: /tmp/filebeat.deb
    - require:
      - pkg: install_wget

# Install Filebeat from downloaded package
install_filebeat_package:
  cmd.run:
    - name: sudo dpkg -i /tmp/filebeat.deb || sudo apt-get install -f -y
    - creates: /usr/bin/filebeat
    - require:
      - cmd: download_filebeat_package

# Create Filebeat config directory
create_filebeat_dir:
  file.directory:
    - name: /etc/filebeat
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: install_filebeat_package

# Filebeat configuration
/etc/filebeat/filebeat.yml:
  file.managed:
    - source: salt://log_collection/filebeat.yml
    - user: root
    - group: root
    - mode: 644
    - require:
      - file: create_filebeat_dir

# Start and enable Filebeat service
start_filebeat_service:
  service.running:
    - name: filebeat
    - enable: True
    - watch:
      - file: /etc/filebeat/filebeat.yml
    - require:
      - cmd: install_filebeat_package
      - file: /etc/filebeat/filebeat.yml

# Install basic log monitoring tools
install_log_tools:
  pkg.installed:
    - pkgs:
      - logwatch
      - sysstat
      - htop
      - iotop