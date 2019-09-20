---
- hosts: 127.0.0.1
  tasks:
  - name: Setup MariaDB repo for CentOS
    yum_repository:
      name: MariaDB
      description: MariaDB Repository
      baseurl: "{{ MariaDB_repo_url }}"
      enabled: "{{ MariaDB_repo_enable }}"
      gpgcheck: "{{ MariaDB_repo_gpgcheck }}"
      gpgkey: "{{ MariaDB_repo_gpg_url }}"
    register: mariadb_repo
    when: ansible_distribution == 'CentOS'

  - name: Install MariaDB Client
    yum:
      name: "{{ item }}"
      state: latest
    with_items:
      - MariaDB-client
      - mariadb-libs
      - MySQL-python
    when: ansible_distribution == 'CentOS'

  - name: copy .my.cnf file with credentials
    template:
      src: templates/root/.my.cnf
      dest: ~/.my.cnf
      owner: root
      mode: 0600

  - name: Create required databases for Openvpn
    mysql_db:
      login_host: "{{ openvpn_database_host }}"
      login_password: "{{ openvpn_database_password }}"
      login_user: "{{ openvpn_database_user }}"
      login_port: "{{ openvpn_database_port }}"
      name: "as_certs"
      state: present

  - name: Create new table as_userprop
    mysql_db:
      login_host: "{{ openvpn_database_host }}"
      login_password: "{{ openvpn_database_password }}"
      login_user: "{{ openvpn_database_user }}"
      login_port: "{{ openvpn_database_port }}"
      name: "as_userprop"
      state: present

  - name: Create new table as_config
    mysql_db:
      login_host: "{{ openvpn_database_host }}"
      login_password: "{{ openvpn_database_password }}"
      login_user: "{{ openvpn_database_user }}"
      login_port: "{{ openvpn_database_port }}"
      name: "as_config"
      state: present

  - name: Create new table as_log
    mysql_db:
      login_host: "{{ openvpn_database_host }}"
      login_password: "{{ openvpn_database_password }}"
      login_user: "{{ openvpn_database_user }}"
      login_port: "{{ openvpn_database_port }}"
      name: "as_log"
      state: present

  - name: Database | Import web certificates before migration
    command: /usr/local/openvpn_as/scripts/sacli --import GetActiveWebCerts
    register: cert_import

  - name: Database | Stop Openvpn server for DB migration
    systemd:
      name: openvpnas
      state: stopped
    when: cert_import.changed
    register: openvpn_stopped

  - name: Migrate certification data to new database
    command: /usr/local/openvpn_as/scripts/dbcvt -t certs -s sqlite:////usr/local/openvpn_as/etc/db/certs.db -d mysql://{{ openvpn_database_user }}:{{ openvpn_database_password }}@{{ openvpn_database_url }}/as_certs
    when: openvpn_stopped.changed
    register: certs_migrated

  - name: Migrate configuration data to new database
    command: /usr/local/openvpn_as/scripts/dbcvt -t config -s sqlite:////usr/local/openvpn_as/etc/db/config.db -d mysql://{{ openvpn_database_user }}:{{ openvpn_database_password }}@{{ openvpn_database_url }}/as_config
    when: certs_migrated.changed
    register: config_migrated

  - name: Migrate log data to new database
    command: /usr/local/openvpn_as/scripts/dbcvt -t log -s sqlite:////usr/local/openvpn_as/etc/db/log.db -d mysql://{{ openvpn_database_user }}:{{ openvpn_database_password }}@{{ openvpn_database_url }}/as_log
    when: config_migrated.changed
    register: logs_migrated

  - name: Migrate user data to new database
    command: /usr/local/openvpn_as/scripts/dbcvt -t user_prop -s sqlite:////usr/local/openvpn_as/etc/db/userprop.db -d mysql://{{ openvpn_database_user }}:{{ openvpn_database_password }}@{{ openvpn_database_url }}/as_userprop
    when: logs_migrated.changed
    register: users_migrated

  - name: Database | Use MySQL database settings
    template:
      src: as.j2
      dest: /usr/local/openvpn_as/etc/as.conf
      mode: 0644
      owner: root
    when: users_migrated.changed
    register: config_updated

  - name: Database | Start openvpnas server for after migration
    systemd:
      name: openvpnas
      state: started
    when: config_updated.changed