# webserver
---
- This is a test dirven cookbook project
`kitchen verify` will automate and test your server configuration
- I have created two instances , one instance is chef-server , the other is a workstation.
- when we spin up the recipe it updates apt cache,enables apache and generate index.html.
- used openssl tool to generate self seigned certificate for our server.
-  configure SSL seetings in apache , where it enable ssl function and configures http redirection.
- Briefly we  create a chef kitchen environment , where we test and automate the recipe , once everything runs good ,destroy the kitchen.
### Instructions

- Usage
  - Before creating test kitchen, modify your .kitchen.yml configration. refer to the example below.
  - **Do not use `kitchen create` to create test kitchen**
  - Just use shell script **kitchen-create.sh** to create test kitchen
  - execute `kitchen verify` to see the test result, and you can go to the public DNS of your instance.
---
```.kitchen.yml example
driver:
  name: ec2
  aws_ssh_key_id: <Your Aws ssh key pair name>
  region: <Your availablety region>
  availability_zone: <Your availiablity zone>
  subnet_id: <Your VPC subnet id>
  instance_type: t2.micro //<- You can keep this unchanged
  image_id: <Your Image Id>
  security_group_ids: <Your SG Id>
  retryable_tries: 120

provisioner:
  name: chef_zero

verifier:
  name: inspec

transport:
  ssh_key: <where your local key pair loaction>

platforms:
  - name: ubuntu-16.04

suites:
  - name: default
    run_list:
      - recipe[webserver-ss::default]
    verifier:
      inspec_tests:
        - test/smoke/default
    attributes:
```
### this is test purpose :rocket: :beer: :boom:
