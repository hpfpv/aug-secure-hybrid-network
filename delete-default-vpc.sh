#!/bin/bash

# Get a list of all available AWS regions
regions=$(aws ec2 describe-regions --query "Regions[].RegionName" --output text)

for region in $regions; do
    echo "Deleting default VPC in region: $region"
    
    # Get the default VPC ID
    default_vpc_id=$(aws ec2 describe-vpcs --region $region --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text)
    
    if [ -n "$default_vpc_id" ]; then
        echo "Default VPC ID in region $region: $default_vpc_id"
        
        VPC_ID=$default_vpc_id

        # Delete subnets in the VPC
        SUBNET_IDS=$(aws ec2 describe-subnets --region $region --filters "Name=vpc-id,Values=$VPC_ID" --query "Subnets[].SubnetId" --output text)
        if [ -n "$SUBNET_IDS" ]; then
            for subnet in $SUBNET_IDS; do
                # Delete the subnet
                aws ec2 delete-subnet --region $region --subnet-id $subnet
            done
        fi

        # # Delete security groups in the VPC
        # SECURITY_GROUP_IDS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" --query "SecurityGroups[].GroupId" --output text)
        # for sg_id in $SECURITY_GROUP_IDS; do
        #     aws ec2 delete-security-group --group-id $sg_id
        # done

        # Delete Internet Gateway attached to the VPC
        IGW=$(aws ec2 describe-internet-gateways --region $region --filters "Name=attachment.vpc-id,Values=$VPC_ID" --query "InternetGateways[].InternetGatewayId" --output text)
        if [ -n "$IGW" ]; then
            # Detach and delete the Internet Gateway
            aws ec2 detach-internet-gateway --region $region --internet-gateway-id $IGW --vpc-id $VPC_ID
            aws ec2 delete-internet-gateway --region $region --internet-gateway-id $IGW
        fi

        # Delete the default VPC
        aws ec2 delete-vpc --region $region --vpc-id $default_vpc_id
        echo "Deleted default VPC in region $region"
    else
        echo "No default VPC found in region $region"
    fi
done