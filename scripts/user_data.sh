#!/bin/bash -x

# Log output from this user_data script.
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

# Set the password for the openvpn user.
export OPENVPN_PASSWORD=`aws --region ${region} ssm get-parameter --name ${ssm_parameter_name} --query 'Parameter.Value' --output text --with-decryption`

echo "#Set password for openvpn user"
echo $OPENVPN_PASSWORD | passwd openvpn --stdin 

# Allow the instance to associate a static IP.
yum install awscli -y
aws ec2 associate-address --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id) --allocation-id ${eip} --allow-reassociation --region ${region}

# Stop the firewalld to allow VPN access.
systemctl stop firewalld
setenforce 0

# Update route 53 records based on new eip.
aws route53 change-resource-record-sets --hosted-zone-id ${hosted_zone_id} --change-batch '{ "Comment": "Update record to reflect new IP address of OpenVPN AS", "Changes": [ { "Action": "UPSERT", "ResourceRecordSet": { "Name": "'${domain_name}'", "Type": "A", "TTL": 120, "ResourceRecords": [ { "Value": "'${eip_ip4}'" } ] } } ] }'

# Install missing pyOpenSSL package in order to run the Ansible playbook.
yum install wget -y
wget -P /opt/ https://cbs.centos.org/kojifiles/packages/pyOpenSSL/0.15.1/1.el7/noarch/pyOpenSSL-0.15.1-1.el7.noarch.rpm
yum install /opt/pyOpenSSL-0.15.1-1.el7.noarch.rpm -y

echo "Pulling down Ansible playbook from S3"
aws s3 cp s3://${s3_bucket}/ansible/openvpn_ssl_ansible_playbook.yaml /opt/openvpn_ssl_ansible_playbook.yaml
aws s3 cp s3://${s3_bucket}/ansible/openvpn_db_ansible_playbook.yaml /opt/openvpn_db_ansible_playbook.yaml

# # Check if the SSL certificates need to be pulled down from S3.
echo "Running Ansible playbook to create/restore SSL certificates"
ansible-playbook -v /opt/openvpn_ssl_ansible_playbook.yaml

echo "Running Ansible playbook to restore RDS connection"
ansible-playbook -v /opt/openvpn_db_ansible_playbook.yaml

# Sleep to allow OpenVPN service to start back up
echo "Sleeping for 10 seconds"
sleep 10

# Correct the OpenVPN configuration.
echo "Updating the OpenVPN configuration."
# Correct the name of the server so its the same as the DNS domain records
/usr/local/openvpn_as/scripts/sacli --key "host.name" --value "${domain_name}" ConfigPut
/usr/local/openvpn_as/scripts/sacli start
/usr/local/openvpn_as/scripts/sacli --key "cs.web_server_name" --value "${domain_name}" ConfigPut
/usr/local/openvpn_as/scripts/sacli start

# Updating access to private networks
/usr/local/openvpn_as/scripts/sacli --key "vpn.server.routing.private_network.0" --value "${private_network_access_1}" ConfigPut
/usr/local/openvpn_as/scripts/sacli start
/usr/local/openvpn_as/scripts/sacli --key "vpn.server.routing.private_network.1" --value "${private_network_access_2}" ConfigPut
/usr/local/openvpn_as/scripts/sacli start

# Turn on/off tunneling VPN traffic
/usr/local/openvpn_as/scripts/sacli --key "vpn.client.routing.reroute_gw" --value "${tunnel_setting}" ConfigPut
/usr/local/openvpn_as/scripts/sacli start

# Restart OpenVPN
echo "Restarting OpenVPN service"
service openvpnas restart 

# Ansible clean up
rm -f /opt/openvpn_ssl_ansible_playbook.yaml
rm -f /opt/openvpn_db_ansible_playbook.yaml
echo "Ansible cleaned up"
echo "OpenVPN start up process complete"
