#!/bin/bash
#
AMI_ID=ami-0220d79f3f480ecf5
SG_ID=sg-0a35f1b312fda2c4d
ZONE_ID="Z03291922N8IYOATZRG2D"
DOMAIN_NAME="govardhanarajus.com"

for instance in $@
do

   INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    #get Private IP
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME" #catalogue.govardhanarajus.com
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN_NAME"    
    fi

    echo "$instance: $IP"

    aws route53 change-resource-record-sets \
   --hosted-zone-id $ZONE_ID \
   --change-batch '{
       "Comment": "updating record set",
       "Changes": [
           {
               "Action": "UPSERT",
               "ResourceRecordSet": {
                   "Name": "'$RECORD_NAME'",
                   "Type": "A",
                   "TTL": 1,
                   "ResourceRecords": [
                       { "Value": "'$IP'" }
                   ]
               }
           }
       ]
   }'
done