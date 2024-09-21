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


 # Set up directories the agent uses
 mkdir -p /var/log/ecs /etc/ecs /var/lib/ecs/data
 # Set up necessary rules to enable IAM roles for tasks
 sysctl -w net.ipv4.conf.all.route_localnet=1
# iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
# iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
 # Run the agent
 docker run --name ecs-agent \
    --detach=true \
    --restart=on-failure:10 \
    --volume=/var/run/docker.sock:/var/run/docker.sock \
    --volume=/var/log/ecs:/log \
    --volume=/var/lib/ecs/data:/data \
    --net=host \
    --env-file=/etc/ecs/ecs.config \
    --env=ECS_LOGFILE=/log/ecs-agent.log \
    --env=ECS_DATADIR=/data/ \
    --env=ECS_ENABLE_TASK_IAM_ROLE=true \
    --env=ECS_ENABLE_TASK_IAM_ROLE_NETWORK_HOST=true \
    amazon/amazon-ecs-agent:latest
