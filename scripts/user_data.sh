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

# Check if the SSL certificates need to be pulled down from S3.
if [ ! -d "/etc/letsencrypt/live/${domain_name}" ] 
then
    echo "Letsencrypt /etc/letsencrypt/live/${domain_name} is not installed!"
    echo "Downloading certificates directly from S3"
    mkdir -p /etc/letsencrypt/live/${domain_name}/
    chmod 0700 -R /etc/letsencrypt/live/${domain_name}/
    aws s3 cp s3://${s3_bucket}/cert/${domain_name}/cert.pem /etc/letsencrypt/live/${domain_name}/cert.pem
    aws s3 cp s3://${s3_bucket}/cert/${domain_name}/chain.pem /etc/letsencrypt/live/${domain_name}/chain.pem
    aws s3 cp s3://${s3_bucket}/cert/${domain_name}/fullchain.pem /etc/letsencrypt/live/${domain_name}/fullchain.pem
    aws s3 cp s3://${s3_bucket}/cert/${domain_name}/privkey.pem /etc/letsencrypt/live/${domain_name}/privkey.pem
    echo "Certificates downloaded from S3"
fi

# Get playbook from S3 and connect VPN server to RDS.
echo "Pulling down Ansible playbook from S3"
aws s3 cp s3://${s3_bucket}/ansible/openvpn_db_restore_ansible_playbook.yaml /opt/openvpn_db_restore_ansible_playbook.yaml
echo "Running Ansible playbook to restore RDS connection"
ansible-playbook -v /opt/openvpn_db_restore_ansible_playbook.yaml

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

# Turn off tunneling VPN traffic
/usr/local/openvpn_as/scripts/sacli --key "vpn.client.routing.reroute_gw" --value "false" ConfigPut
/usr/local/openvpn_as/scripts/sacli start

# Restart OpenVPN
echo "Restarting OpenVPN service"
service openvpnas restart 