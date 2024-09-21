#!/bin/bash

# Update all installed packages and install needed dependencies
yum update -y
yum install -y amazon-linux-extras

# Install Docker
amazon-linux-extras install docker -y
service docker start

# Enable Docker to start on boot
systemctl enable docker

# Add the 'ec2-user' (or current user) to the docker group to run Docker without sudo
usermod -a -G docker ec2-user

# Install ECS Agent (ecs-init)
yum install -y ecs-init

# Create the ECS config file with the cluster name
echo "ECS_CLUSTER=my-ecs-cluster" > /etc/ecs/ecs.config

# (Optional) Specify ECS Instance Attributes (if needed)
#echo "ECS_INSTANCE_ATTRIBUTES={\"instanceType\":\"t2.medium\"}" >> /etc/ecs/ecs.config

# (Optional) Enable IAM Roles for tasks running on EC2 instances
echo "ECS_ENABLE_TASK_IAM_ROLE=true" >> /etc/ecs/ecs.config
echo "ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true" >> /etc/ecs/ecs.config

# (Optional) Specify available logging drivers
echo "ECS_AVAILABLE_LOGGING_DRIVERS='[\"json-file\",\"awslogs\"]'" >> /etc/ecs/ecs.config

# Start the ECS agent
systemctl start ecs

# Enable ECS agent to start on boot
systemctl enable ecs

