


openvpn_server_domain = ${var.openvpn_server_domain}
hostname: vpn-server-foobar

# General settings | MFA
openvpn_enable_mfa: true

# General settings | SSL
use_ssl: true
ssl_admin_email: foo@bar.com

# Openvpn package details
openvpn_pkg_dir: /opt/packages
ubuntu_version: 16
openvpnas_deb_url: "https://openvpn.net/downloads/openvpn-as-latest-ubuntu{{ ubuntu_version }}.amd_64.db"
centos_version: 7
openvpnas_cent_url: "https://openvpn.net/downloads/openvpn-as-latest-CentOS{{ centos_version }}.x86_64.rpm"

# OpenVPN server user
openvpn_server_user: openvpn

# OpenVPN server password
openvpn_server_password: welcome1

# Service states: started or stopped
openvpnas_service_state: stopped

# Service enabled on startup: yes or no
openvpnas_service_enabled: no

# EPEL Repo details | Only for CentOS
epel_repo_url: "https://dl.fedoraproject.org/pub/epel/epel-release-latest-{{ ansible_distribution_major_version }}.noarch.rpm"
epel_repo_gpg_key_url: "https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-{{ ansible_distribution_major_version }}"
epel_repofile_path: "/etc/yum.repos.d/epel.repo"

# Maria DB Repo details | Only for CentOS
MariaDB_repo_url: http://yum.mariadb.org/10.1/centos7-amd64
MariaDB_repo_enable: yes
MariaDB_repo_gpgcheck: yes
MariaDB_repo_gpg_url: https://yum.mariadb.org/RPM-GPG-KEY-MariaDB

# OpenVPN Database Details | You need RDS setup to use these!
openvpn_database_user: openvpn-db-user
openvpn_database_password: welcome1
openvpn_database_host: 127.0.0.1
openvpn_database_port: 3306
openvpn_database_url: "{{ openvpn_database_host }}:{{ openvpn_database_port }}"
openvpn_databases:
  - as_certs
  - as_userprop
  - as_config
  - as_log

# OpenVPN Configuration Settings
openvpnas_base_path: "/usr/local/openvpn_as"
openvpnas_etc_path: "{{openvpnas_base_path}}/etc"
openvpnas_profile: "Default"

# OpenVPN Network Settings
openvpn_network_config:
  vpn.server.routing.private_access: "nat"
  vpn.server.routing.private_network.0: ""
  vpn.client.routing.reroute_gw: "false"
  vpn.server.routing.gateway_access: "false"
  vpn.client.routing.reroute_dns: ""
  vpn.server.dhcp_option.dns.0: ""

