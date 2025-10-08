#!/bin/bash
#
AMI_ID=ami-09c813fb71547fc4f
SG_ID=sg-0caa92da7b80302bc

for instance in $@
do

   INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0caa92da7b80302bc --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    #get Private IP
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0caa92da7b80302bc --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].PrivateIpAddress' --output text)
    else
        IP=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-0caa92da7b80302bc --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].PublicIpAddress' --output text)
    fi

    echo "$instance: $IP"
done