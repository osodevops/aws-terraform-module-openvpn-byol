#!/bin/bash -x

#log output from this user_data script
exec > >(tee /var/log/user-data.log|logger -t user-data ) 2>&1

# Allow the instance to associate a static IP
yum install awscli -y
aws ec2 associate-address --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id) --allocation-id ${eip} --allow-reassociation --region ${region}

# Stop the firewalld to allow VPN access
systemctl stop firewalld
setenforce 0

# Update route 53 records based on new eip
aws route53 change-resource-record-sets --hosted-zone-id ${hosted_zone_id} --change-batch '{ "Comment": "Update record to reflect new IP address of OpenVPN AS", "Changes": [ { "Action": "UPSERT", "ResourceRecordSet": { "Name": "'${domain_name}'", "Type": "A", "TTL": 120, "ResourceRecords": [ { "Value": "'${eip_ip4}'" } ] } } ] }'

# Install missing pyOpenSSL package
yum install wget -y
wget  -P /opt/ https://cbs.centos.org/kojifiles/packages/pyOpenSSL/0.15.1/1.el7/noarch/pyOpenSSL-0.15.1-1.el7.noarch.rpm
yum install /opt/pyOpenSSL-0.15.1-1.el7.noarch.rpm -y

# Check if the SSL certificates need to be downloaded
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
fi

# Get playbook from S3
aws s3 cp s3://${s3_bucket}/ansible/openvpn_db_restore_ansible_playbook.yaml /opt/openvpn_db_restore_ansible_playbook.yaml

# Connect VPN server to RDS
ansible-playbook -v /opt/openvpn_db_restore_ansible_playbook.yaml

# Restart OpenVPN
service openvpnas restart