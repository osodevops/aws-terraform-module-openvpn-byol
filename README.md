[<img src="https://osodevops.io/assets/images/logo-purple-b3af53cc.svg" width="250"/>](https://osodevops.io)

# aws-terraform-module-openvpn-byol
---

This project is part of our open source DevOps adoption approach. 

It's 100% Open Source and licensed under the [APACHE2](LICENSE).

This module deploys ready-to-go OpenVPN Access Server AMI with an RDS backend and Letsencrypt for SSL certificate generation.

The module requires the following:
* `terraform` version >= 0.12.0
* `aws` provider ~> 2.7
* OpenVPN Access Server AMI (we recommend building it with [Codebuild](https://github.com/osodevops/aws-terraform-module-codebuild-packer))

### How does it work?

The OpenVPN server sits inside of a autoscaling group and is deployed into public subnet within a nominated VPC in order to ring-fence the solution. VPN client users can connect to the OpenVPN server creating a dedicated layer 4 tunnels which the VPN users can then use to access internal services hosted in the nominated VPC or in adjacent VPC attached via VPC-peering. The OpenVPN server can also provide access to any internal Route53 hosted zone by DNS proprigation. Access to the OpnVPN server for administrative tasks can be done either through the admin GUI on port 943 or via the AWS System Manager, which creates an SSH session via the AWS console. Port 22 is not open on this server, access directly via SSH is not enabled for improved protection against attackers, we recommend to all our clients to use AWS Session Manager instead, to find out more please see the [following page](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html).

![Diagram](https://lucid.app/publicSegments/view/1fcff661-1dfc-4ce8-b77c-f9b2f59fba8a/image.png)

In this solution OpenVPN Access Server is configured to migrate its local SQLite database to Aurora RDS to allow for data persistance, the migration process is fully automated using Ansible playbooks which are stored in S3 and are generated during the Terraform run. These Ansible playbooks are later pulled down from S3 and run locally as part of the user-data boot procedure. This means that the no matter what happens to the EC2 instance the AutoScalingGroup will replace it with a new instance and during the boot up sequence of that instance, Ansible will check if it needs to migrate the database or update the configuration file on the EC2 instance to ensure OpenVPN Access Server is using the database stored in Aurora RDS. The ansible playbooks will also generate SSL certificates everytime a new EC2 instance is deployed and store the ceritifcates in S3 so they can be pulled down again and reused in case a new instance needs to be spun up. 

Since developing this solution, Letsencrypt have reduced the longevity of thier SSL certificates, we now recommend terminating your EC2 instance on a regular basis allow for Letsencrypt to generate a new certificate.

To read the Ansible playbooks, please go [here](https://github.com/osodevops/aws-terraform-module-openvpn-byol/tree/master/ansible).

## Usage

Include this repository as a module in your existing terraform code:
```hcl
module "openvpn" {
  source = "git::ssh://git@github.com/osodevops/aws-terraform-module-ssm-session-manager.git"
}
```

### Using Regular Terraform Commands:
*You might have to initialise the terraform workspace, in order to do so run:*
```bash
terraform init -reconfigure
```

1. Check that your code is good and what you are building, run:
```bash
terraform plan -refresh=true
```

You should see an output from terraform suggesting building a set of services;
- EC2 AutoScalingGroup for the OpenVPN server.
- S3 bucket with an s3 bucket policy.
- S3 objects for the Ansible playbooks.
- RDS Aurora cluster.

2. When you are happy with the proposed creations, changes, execute the following:
```bash
terraform apply -auto-approve
```

### Ansible Playbooks

OpenVPN Access Server is not very automation friendly, hence there are times when we may need to manually run the Ansible playbooks that configure the VPN service. There are currently 3 ansible playbooks that configure the OpenVPN server.
1. db_tasks.yaml
  * This playbook is used to both migrate the database of a new OpenVPN implementation to RDS and also restore the OpenVPN configuration against a current OpenVPN database in RDS. This is the default playbook run against the server during a deployment, there is conditional logic in the playbook to know when to migrate and when to restore the database.
2. ssl_automation.yaml
  * This playbook generates a custom SSL certificate using Letsencrypt, which gets ingested into OpenVPN. The certificate lasts for 60 days. Simply run the playbook to renew the certificate.
3. openvpn_update_ansible_playbook.yaml 
  * This playbook will update the packages on the server. OpenVPN servers can become long-lived hence they need to be updated from time to time. You could setup a cron in Cloudwatch to run this command on a regular basis.

To invoke the playbooks listed above use the SSM documents generated [here](https://github.com/osodevops/aws-terraform-module-openvpn-byol/blob/master/aws_ssm_commands.tf) and with the following terraform command;
```bash
terraform apply -auto-approve -var="run_ssl_playbook=true" -target=module.vpn.aws_ssm_association.ssl_ansible_playbook[0]
```
Please adjust the SSM code to meet your needs, they are only examples of what is possible.

In order for the AutoScalingGroup's to run the Ansible playbooks as part of the user-data procedure all of the Ansible playbooks are stored in S3 and pulled down by the [bash script](https://github.com/osodevops/aws-terraform-module-openvpn-byol/blob/master/scripts/user_data.sh) and run locally as follows:
```bash
ansible-playbook -v /opt/openvpn_ssl_ansible_playbook.yaml
```
Should you wish you can also pull down and run the ansible playbooks locally on the EC2 instance via SSM. However be aware that due to the conditional logic used in the Ansible playbooks, you cannot use "Check Mode". You will recieve an error from Ansible if you use `--check` when running the Ansible playbooks, this is expected.

**WARNING**

OpenVPN is an expert level program, the application is very unforgiving if mistakes are made. Only run the commands below if you know what you are doing. If debugging is required please logon via SSM directly to the server and check the `/var/log/opevpnas.log` and query the database for configuration settings via the `./sacli` tool. 

Please use the following guide for specific [OpenVPN Access Server commands](https://openvpn.net/access-server-manual/introduction/), there is a lot of good documentation in there.

Be aware that if you use Google Authentication with OpenVPN Access Server, you will need to run [these commands](https://openvpn.net/vpn-server-resources/google-authenticator-multi-factor-authentication/) locally on the EC2 instance in order to reset users tokens.

**WARNING**

## Inputs

The following arguments are supported:

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami_owner_account | Provide the AWS ID for the AMI owner | string | n/a | yes |
| asg_min_size | Minimum size of ASG | string | 1 | no |
| asg_max_size | Maximum size of ASG | string | 1 | no |
| asg_desired_capacity | Desired capacity of ASG | string | 1 | no |
| db_instance_type | Size of the RDS instance | string | db.t2.small | yes |
| ec2_instance_type | Size of the EC2 instance | string | t2.small | yes |
| environment | DEV/MGMT/TEST/PROD? | string | n/a | no |
| iam_role_name | Name of the IAM role used	 | string | n/a | yes |
| iam_policy_name | Name of the IAM policy used	 | string | n/a | yes |
| iam_instance_profile_name | Name of the IAM instance policy used | string | n/a | yes |
| key_name | EC2 SSH key used for deployment	 | string | n/a | yes |
| rds_backup_retention_period | Set the rention period for the RDS backups | string | 7 | no |
| rds_preferred_backup_window | Set the preferred backup window for the RDS instance | string | 01:00-03:00 | no |
| rds_maintenance_window | Set the maintenance window for the RDS instance	 | string | sun:03:00-sun:04:00 | no |
| rds_storage_encrypted | Encrypt RDS, yes/no? | string | true | no |
| rds_master_name | Set the DB username	 | string | n/a | yes |
| rds_master_password | Set the DB password | string | n/a | yes |
| rds_database_name | Set the name of the DB | string | openvpndb | no |
| rds_cluster_identifier | Name of the RDS cluster | string | openvpn-database-cluster | no |
| rds_instance_name | RDS instance name	| string | openvpn-database-instance | no |
| rds_subnet_group | Subnet group used for the deployment	| string | openvpn-db-subnet-group | no |
| rds_final_snapshot | Set the name for the final snapshot if an RDS instance is terminated | string | openvpn-db-snapshot-final | no |
| rds_port | RDS port for the database | string | 3306 | no |
| r53_domain_name | Set the domain name used by the OpenVPN server | string | n/a | yes |
| r53_hosted_zone_id | R53 hosted zone used by the OpenVPN server | string | n/a | yes |
| vpc_id | Set the VPC ID	| string | n/a | yes |
| vpc_cidr_range | CIDR Range for the VPC | string | n/a | yes |
| aws_region | Region used in AWS | string | n/a | yes |
| common_tags | Common tags used for all AWS resources in the TF module | string | n/a | yes |
| s3_bucket_acl | S3 Acess controls | string | private | no |
| s3_bucket_force_destroy | Do you want to force destruction of S3 objects when rebuilding the TF stack?	 | string | n/a | yes |
| s3_bucket_name_ansible | Set the name of the S3 bucket used	 | string | n/a | yes |
| s3_bucket_policy | Set a custom S3 policy used by the S3 bucket	 | string | n/a | yes |
| bucket_versioning | Set S3 bucket versioning? | string | false | no |
| s3_sse_algorithm | Which algorithm to use for S3 encryption | string | AES256 | no |
| mariadb_repo_url | Repo URL for MariaDB | string | http://yum.mariadb.org/10.1/centos7-amd64 | no |
| mariadb_repo_enable | Enable repo for MariaDB | string | yes | no |
| mariadb_repo_gpgcheck | GPG check MariaDB repo | string | yes | no |
| mariadb_repo_gpg_url | GPG check key url | string | https://yum.mariadb.org/RPM-GPG-KEY-MariaDB | no |
| openvpn_database_user | OpenVPN database user | string | openvpn-db-user | no |
| openvpn_dns_name | URL for the OpenVPN database | string | n/a | yes |
| ec2_hostname | hostname of the ec2 instance | string | n/a | yes |
| ssl_admin_email | set an email for the ssl certificates, letsencrypt will notify you when certs expire | string | n/a | yes |
| epel_repofile_path | EPEL repo file path | string | /etc/yum.repos.d/epel.repo | no |
| epel_repo_gpg_key_url | EPEL GPG key URL | string | https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 | no |
| epel_repo_url | EPEL Repo URL | string | https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm | no |
| snapshot_identifier | Set the name for an existing RDS snapshot | string | n/a | yes |
| ssm_parameter_name | Set the SSM parameter name for the openvpn password | string | n/a | yes |
| private_network_access_1 | Set the network address that OpenVPN will allow routing access to | string | n/a | yes |
| private_network_access_2 | Set the network address that OpenVPN will allow routing access to | string | n/a | yes |
| deletion_protection | RDS delete protection | string | true | no |
| multi_az | RDS multi AZ | string | false | no |
| apply_immediately | RDS apply changes immediatly option | string | false | no |
| aws_ami_filter | Set a custom filter for the OpenVPN access server | string | OPENVPN-*| no |
| vpn_tunnel_setting | Set the VPN tunneling mode to be ON or OFF | string | false | no |

## Help

**Got a question?**

File a GitHub [issue](https://github.com/osodevops/aws-terraform-module-openvpn-byol/issues), send us an [email][email] or tweet us [twitter][twitter].

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/osodevops/aws-terraform-module-openvpn-byol/issues) to report any bugs or file feature requests.

### Developing

If you are interested in being a contributor and want to get involved in developing this project or help out with our other projects, we would love to hear from you! Shoot us an [email][email].

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!

## Copyrights

Copyright © 2019-2021 [OSO DevOps](https://osodevops.io)

## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.

## Trademarks

All other trademarks referenced herein are the property of their respective owners.

## About

[<img src="https://osodevops.io/assets/images/logo-purple-b3af53cc.svg" width="250"/>](https://osodevops.io)

We are a cloud consultancy specialising in transforming technology organisations through DevOps practices. 
We help organisations accelerate their capabilities for application delivery and minimize the time-to-market for software-driven innovation. 

Check out [our other projects][github], [follow us on twitter][twitter], or [hire us][hire] to help with your cloud strategy and implementation.

  [logo]: https://osodevops.io/assets/images/logo-purple-b3af53cc.svg
  [website]: https://osodevops.io/
  [github]: https://github.com/orgs/osodevops/
  [hire]: https://osodevops.io/contact/
  [linkedin]: https://www.linkedin.com/company/oso-devops
  [twitter]: https://twitter.com/osodevops
  [email]: https://www.osodevops.io/contact/
