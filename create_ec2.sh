#!/bin/bash

set -euo pipefail

# AWS Configuration
AWS_REGION="eu-west-1"
export AWS_DEFAULT_REGION="$AWS_REGION"

LOG="aws_setup.log"
KEY_NAME="my-ec2-key-pair"
KEY_FILE="${KEY_NAME}.pem"
INSTANCE_TYPE="t3.micro"
AMI_ID="ami-0c13c2049f369d641"
TAG="Project=AutomationLab"

# Custom logging function
log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level] - $message" | tee -a "$LOG"
}

log "INFO" "Starting EC2 automation setup in region: $AWS_REGION..."

# Create key pair with aws create-key-pair
if aws ec2 describe-key-pairs --key-names "$KEY_NAME" > /dev/null 2>&1; then
    log "WARN" "Key pair '$KEY_NAME' already exists — skipping"
else
    log "INFO" "Creating key pair '$KEY_NAME'..."
    aws ec2 create-key-pair \
        --key-name "$KEY_NAME" \
        --query "KeyMaterial" \
        --output text > "$KEY_FILE"

    chmod 400 "$KEY_FILE"
    log "INFO" "Key pair '$KEY_NAME' created and saved to $KEY_FILE with secure permissions."
fi

log "INFO" "Launching EC2 instance (Type: $INSTANCE_TYPE, AMI: $AMI_ID)..."

# Create ec2 instance
INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --count 1 \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Project,Value=AutomationLab}]" \
    --query "Instances[0].InstanceId" \
    --output text)

log "INFO" "Instance created successfully. Instance ID: $INSTANCE_ID"

log "INFO" "Waiting for instance to transition to 'running' state to fetch Public IP..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query "Reservations[0].Instances[0].PublicIpAddress" \
    --output text)


echo " Deployment Complete!"
echo " Instance ID: $INSTANCE_ID"
echo " Public IP:    $PUBLIC_IP"


log "INFO" "Automation script finished successfully."