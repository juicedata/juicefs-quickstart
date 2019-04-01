# JuiceFS Quick Start

[![asciicast](https://asciinema.org/a/232804.svg)](https://asciinema.org/a/232804)

JuiceFS is a shared POSIX file system for the cloud.

You may replace existing solutions with JuiceFS with zero cost, turns any object store into a shared POSIX file system.

To get started with JuiceFS, just follow the steps below.

## Provision the resources

JuiceFS stores user data in object storage such as AWS S3, Aliyun OSS and etc and it can be **shared across available zones**. In this example, we will provision several instances in different availability zones.

```shell
cd terraform
terraform init
terraform apply
```

It will create the following resources:

- EC2 instances to mount JuiceFS
- S3 bucket to store filesystem data
- IAM role to grant EC2 instance fullaccess to the bucket
- Security group for SSH access to the EC2 instances

For simplicity, we create the EC2 instances in default VPC and subnet in this example.

When provision is completed, you should get outputs for ansible inventory and SSH commands to login the servers

```console
Outputs:

ansible_inventory = juicefs-quickstart-0 ansible_host=54.65.83.217 ansible_user=centos ansible_ssh_common_args='-o StrictHostKeyChecking=no'
juicefs-quickstart-1 ansible_host=13.231.175.188 ansible_user=centos ansible_ssh_common_args='-o StrictHostKeyChecking=no'
juicefs-quickstart-2 ansible_host=18.179.59.114 ansible_user=centos ansible_ssh_common_args='-o StrictHostKeyChecking=no'
ssh_commands = [
    ssh -i ~/.ssh/id_rsa centos@54.65.83.217,
    ssh -i ~/.ssh/id_rsa centos@13.231.175.188,
    ssh -i ~/.ssh/id_rsa centos@18.179.59.114
]
```

You can save the output to Ansible inventory by

```shell
terraform output ansible_inventory > ../ansible/hosts
```

## Deployment

In `ansible` directory, run the following command

```shell
cd ../ansible
export JFS_NAME=<your-juicefs-name>
export JFS_TOKEN=<your-juicefs-token>
ansible-playbook deploy-juicefs.yaml --extra-vars="jfs_name=$JFS_NAME jfs_token=$JFS_TOKEN"
```

## Testing

Create file in one host and visit it from others without extra effort.

```shell
ANSIBLE_STDOUT_CALLBACK=unixy ansible-playbook test-juicefs.yaml
```

## Destroy

1. Go to [AWS console for S3](https://s3.console.aws.amazon.com/s3/buckets/) and empty s3 bucket
2. In `terraform` directory, run the following command

```shell
cd ../terraform
terraform destroy
```

## Troubleshooting

### BucketNotEmpty: The bucket you tried to delete is not empty

If you get the following error during destroy

```console
* aws_s3_bucket.this: error deleting S3 Bucket (juicefs-quickstart): BucketNotEmpty: The bucket you tried to delete is not empty
	status code: 409, request id: 01140C746618B468, host id: DVJ3RUMcyJo8HJyQsHcWNcNcsiDA0raIB8ABU0nt1iHsMrZ/dEQut7jeeZr31OA/urx+wyGjEk8=
```

Go to AWS console to check whether the S3 bucket has been emptied or not and rerun

```shell
terraform destroy
```

### Failed to connect to the host via ssh

```console
ansible-playbook deploy-juicefs.yaml
...
TASK [Download juicefs CLI] ****************************************************
fatal: [juicefs-quickstart-1]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: ssh: connect to host 54.250.184.85 port 22: Connection refused", "unreachable": true}
fatal: [juicefs-quickstart-0]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: ssh: connect to host 13.114.104.39 port 22: Connection refused", "unreachable": true}
fatal: [juicefs-quickstart-2]: UNREACHABLE! => {"changed": false, "msg": "Failed to connect to the host via ssh: ssh: connect to host 13.230.38.252 port 22: Connection refused", "unreachable": true}
	to retry, use: --limit @/Users/yujunz/Code/juicedata/juicefs-quickstart/ansible/deploy-juicefs.retry
```

The EC2 instances may take some time to boot up. Check the status in AWS console and try again later.

## Reference

- [How to deploy JuiceFS](https://juicefs.com/docs/en/deployment.html)
