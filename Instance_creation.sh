#!/bin/bash
NAMES=("Mongodb" "web" "Catalogue" "Cart" "Shipping" "User" "Mysql" "Redis" "RabbitMq" "Dispatch" "Payment")
Instance_Type=""
Security_Group_Id="sg-03385513c7e65e046"
Image_Id="ami-03265a0778a880afb"
Ip_Address=""
for i in "${NAMES[@]}"
do
    if [[ $i==Mongodb || $i==Mysql ]];
    then
        Instance_Type="t3.medium"
    else
        Instance_Type="t2.micro"
    fi
    echo "creating $i instance"
    aws ec2 run-instances --image-id $Image_Id --instance-type $Instance_Type --security-group-ids $Security_Group_Id --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]"
done
