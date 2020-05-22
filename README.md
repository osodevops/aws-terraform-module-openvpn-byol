[![OSO DevOps][logo]](https://osodevops.io)

# aws-terraform-module-openvpn
---

This project is part of our open source DevSecOps adoption approach. 

It's 100% Open Source and licensed under the [APACHE2](LICENSE).

This module deploys OpenVPN Access Server with an RDS backend and Letsencrypt for SSL certificate generation.

The module requires the following:
* `terraform` version >= 0.12.0
* `aws` provider ~> 2.7

## Usage

Include this repository as a module in your existing terraform code:
```hcl
module "openvpn" {
  source = "git::ssh://git@github.com/osodevops/aws-terraform-module-ssm-session-manager.git"
}
```

## Inputs

The following arguments are supported:

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| ami_owner_account |  | string | n/a | yes |
| asg_min_size |  | string | n/a | yes |
| asg_max_size |  | string | n/a | yes |
| asg_desired_capacity |  | string | n/a | yes |
| db_instance_type |  | string | n/a | yes |
| ec2_instance_type |  | string | n/a | yes |
| environment |  | string | n/a | yes |
| iam_role_name |  | string | n/a | yes |
| iam_policy_name |  | string | n/a | yes |
| iam_instance_profile_name |  | string | n/a | yes |
| key_name |  | string | n/a | yes |
| rds_backup_retention_period |  | string | n/a | yes |
| rds_preferred_backup_window |  | string | n/a | yes |
| rds_maintenance_window |  | string | n/a | yes |
| rds_storage_encrypted |  | string | n/a | yes |
| rds_master_name |  | string | n/a | yes |
| rds_master_password |  | string | n/a | yes |
| rds_database_name |  | string | n/a | yes |
| rds_cluster_identifier |  | string | n/a | yes |
| rds_instance_name |  | string | n/a | yes |
| rds_subnet_group |  | string | n/a | yes |
| rds_final_snapshot |  | string | n/a | yes |
| rds_port |  | string | n/a | yes |
| r53_domain_name |  | string | n/a | yes |
| r53_hosted_zone_id |  | string | n/a | yes |
| vpc_id |  | string | n/a | yes |
| vpc_cidr_range |  | string | n/a | yes |
| aws_region |  | string | n/a | yes |
| common_tags |  | string | n/a | yes |
| s3_bucket_acl |  | string | n/a | yes |
| s3_bucket_force_destroy |  | string | n/a | yes |
| s3_bucket_name_ansible |  | string | n/a | yes |
| s3_bucket_policy |  | string | n/a | yes |
| bucket_versioning |  | string | n/a | yes |
| s3_sse_algorithm |  | string | n/a | yes |
| mariadb_repo_url |  | string | n/a | yes |
| mariadb_repo_enable |  | string | n/a | yes |
| mariadb_repo_gpgcheck |  | string | n/a | yes |
| mariadb_repo_gpg_url |  | string | n/a | yes |
| openvpn_database_user |  | string | n/a | yes |
| openvpn_dns_name |  | string | n/a | yes |
| ec2_hostname |  | string | n/a | yes |
| ssl_admin_email |  | string | n/a | yes |
| epel_repofile_path |  | string | n/a | yes |
| epel_repo_gpg_key_url |  | string | n/a | yes |
| epel_repo_url |  | string | n/a | yes |
| run_full_system_update |  | string | n/a | yes |
| run_db_migration_playbook |  | string | n/a | yes |
| run_db_restore_playbook |  | string | n/a | yes |
| run_ssl_playbook |  | string | n/a | yes |
| run_update_server_playbook |  | string | n/a | yes |
| snapshot_identifier |  | string | n/a | yes |
| ssm_parameter_name |  | string | n/a | yes |
| private_network_access_1 |  | string | n/a | yes |
| private_network_access_2 |  | string | n/a | yes |
| deletion_protection |  | string | n/a | yes |
| multi_az |  | string | n/a | yes |
| apply_immediately |  | string | n/a | yes |
| aws_ami_filter |  | string | n/a | yes |
| vpn_tunnel_setting |  | string | n/a | yes |

## Help

**Got a question?**

File a GitHub [issue](https://github.com/osodevops/aws-terraform-module-codebuild-packer/issues), send us an [email][email] or tweet us [twitter][twitter].

## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/osodevops/aws-terraform-module-codebuild-packer/issues) to report any bugs or file feature requests.

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

Copyright © 2018-2019 [OSO DevOps](https://osodevops.io)

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

[![OSO DevOps][logo]][website]

We are a cloud consultancy specialising in transforming technology organisations through DevOps practices. We help organisations accelerate their capabilities for application delivery and minimize the time-to-market for software-driven innovation. 

Check out [our other projects][github], [follow us on twitter][twitter], or [hire us][hire] to help with your cloud strategy and implementation.

  [logo]: https://osodevops.io/assets/images/logo-purple-b3af53cc.svg
  [website]: https://osodevops.io/
  [github]: https://github.com/orgs/osodevops/
  [hire]: https://osodevops.io/contact/
  [linkedin]: https://www.linkedin.com/company/oso-devops
  [twitter]: https://twitter.com/osodevops
  [email]: https://www.osodevops.io/contact/