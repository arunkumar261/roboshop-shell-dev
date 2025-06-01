#!/bin/bash

AMI_ID=ami-0b4f379183e5706b9
SG_ID=sg-0dccc737241e3f233
INSTANCES=("mongdb","redis","mysql","rabbitmq","catalogue","user","cart","shipping","payment","dispatch","web" )


for i in "$(INSTANCES[@])"
do
if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
then
    INSTANCE_TYPE="t3.small"
else
    INSTANCE_TYPE="t2.micro"
fi
    aws ec2 run-instances --image-id $AMI_ID --instance-type $INSTANCE_TYPE
    --security-group-ids $SG_ID
done
