#!/bin/bash

AMI=ami-0b4f379183e5706b9 #this keeps on changing
SG_ID=sg-0dccc737241e3f233 #replace with your SG ID
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
# ZONE_ID=Z00836682TJ775V3EAIOJ # replace your zone ID
# DOMAIN_NAME="arundev.store"

for i in "${INSTANCES[@]}"
do
    echo "Instance is : $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t3.small"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids sg-0dccc737241e3f233 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"
done