#!/bin/bash

set -euo pipefail


SG_NAME="devops-sg"
SG_DESC="DevOps security group with SSH and HTTP access"
VPC_ID="vpc-051287293dbe9724f"
REGION="eu-west-1"

#Create the Security Group
echo "Creating security group '$SG_NAME'..."

SG_ID=$(aws ec2 create-security-group \
  --group-name "$SG_NAME" \
  --description "$SG_DESC" \
  --vpc-id "$VPC_ID" \
  --region "$REGION" \
  --query 'GroupId' \
  --output text)

echo "Security Group Created — ID: $SG_ID"

#Open Port 22 (SSH)
echo "Adding SSH rule (port 22)..."

aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region "$REGION"

echo "Port 22 (SSH) opened."

#Open Port 80 (HTTP)
echo "Adding HTTP rule (port 80)..."

aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0 \
  --region "$REGION"

echo "Port 80 (HTTP) opened."

#Display Security Group ID and Rules
echo "===== Security Group Summary ====="
echo "Security Group ID: $SG_ID"
echo ""
echo "Inbound Rules:"

aws ec2 describe-security-groups \
  --group-ids "$SG_ID" \
  --region "$REGION" \
  --query 'SecurityGroups[0].IpPermissions[*].{Port:FromPort,Protocol:IpProtocol,CIDR:IpRanges[0].CidrIp}' \
  --output table

echo "Done!"