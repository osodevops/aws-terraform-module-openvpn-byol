---

- name: Config | Check that Openvpn is running
  systemd:
    name: openvpnas
    state: started

- name: Config | Apply network settings
  command: /usr/local/openvpn_as/scripts/sacli --key "{{ item.key }}" --value "{{ item.value }}" ConfigPut
  with_dict: "{{ openvpn_network_config }}"
  when: ( use_network_settings|bool )
  notify: Update openvpn

- name: Config | Enable MFA
  command: /usr/local/openvpn_as/scripts/sacli --key "vpn.server.google_auth.enable" --value "true" ConfigPut
  when: ( openvpn_enable_mfa|bool )
  notify: Update openvpn

- name: Config | Apply LDAP settings
  command: /usr/local/openvpn_as/scripts/sacli --key "{{ item.key }}" --value "{{ item.value }}" ConfigPut
  with_dict: "{{ openvpn_ldap_config }}"
  when: ( use_ldap_authentication|bool )
  notify: Update openvpn
  register: openvpn_apply_ldap

- name: Config | Activate LDAP
  command: /usr/local/openvpn_as/script/sacli --key "auth.module.type" --value "ldap" ConfigPut
  when: openvpn_apply_ldap.changed
  notify: Update openvpn