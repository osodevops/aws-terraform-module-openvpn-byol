---
- hosts: 127.0.0.1
  tasks:
    - name: Cerbot | Check if EPEL repo is already configured.
      stat: path={{ epel_repofile_path }}
      register: epel_repofile_result

    - name: Cerbot | Install EPEL repo.
      yum:
        name: "{{ epel_repo_url }}"
        state: present
      register: result
      when: not epel_repofile_result.stat.exists

    - name: Cerbot | Import EPEL GPG key.
      rpm_key:
        key: "{{ epel_repo_gpg_key_url }}"
        state: present
      when: not epel_repofile_result.stat.exists

    - name: Cerbot | Install Cerbot
      yum:
        name: certbot
        state: present
      notify: Stop VPN service

    - name: Cerbot | Request certificate
      command: certbot certonly --standalone -d {{ openvpn_server_domain }} --email {{ ssl_admin_email }} --agree-tos
      register: certificate_request

    - name: Certbot | Start VPN service
      systemd:
        name: openvpnas
        state: restarted
      when: certificate_request.changed

    - name: Cerbot | Upload ca_bundle
      command: /usr/local/openvpn_as/scripts/confdba -mk cs.ca_bundle -v "`cat /etc/letsencrypt/live/{{ openvpn_server_domain }}/fullchain.pem`"

    - name: Cerbot | Upload priv_key
      command: /usr/local/openvpn_as/scripts/confdba -mk cs.priv_key -v "`cat /etc/letsencrypt/live/{{ openvpn_server_domain }}/privkey.pem`" > /dev/null

    - name: Certbot | Upload certificate
      command: /usr/local/openvpn_as/scripts/confdba -mk cs.cert -v "`cat /etc/letsencrypt/live/{{ openvpn_server_domain }}/cert.pem`"

    - name: Certbot | Restart VPN service
      systemd:
        name: openvpnas
        state: restarted