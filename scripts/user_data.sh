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