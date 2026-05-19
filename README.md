# AWS Automation Lab — EC2, Security Groups & S3

## Overview

This lab demonstrates how to automate the creation and configuration of essential AWS resources using Bash scripts and the AWS CLI. The scripts cover EC2 key pair creation, EC2 instance launching, security group setup, and S3 bucket management — all with built-in logging, error handling, and duplicate checks.

---

## Purpose of Each Script

### `create_ec2.sh`
Creates an EC2 key pair and launches a free-tier Amazon Linux 2 EC2 instance. It tags the instance, waits for it to enter a running state, and prints the instance ID and public IP upon completion.

### `create_security_group.sh`
Creates a new EC2 security group and configures inbound rules to allow SSH (port 22) and HTTP (port 80) traffic. Includes a check to skip creation if the security group already exists.

### `create_s3_bucket.sh`
Creates an S3 bucket with a unique name, enables versioning, and apply bucket policy. Includes a check to skip creation if the bucket already exists.

---

## Project Structure

```
aws_auto/
├── create_ec2.sh             # EC2 instance creation script
├── create_security_group.sh  # Security group creation script
├── create_s3_bucket.sh       # S3 bucket creation script
├── aws_setup.log             # Log file for creating EC2 instance
└── README.md                 # This file
```

---

## Prerequisites

### Tools Required

| Tool | Purpose | Check |
|------|---------|-------|
| AWS CLI | Interact with AWS services | `aws --version` |
| Bash | Run the scripts | `bash --version` |
| Git | Version control | `git --version` |

### AWS Permissions Required

Your AWS user or role must have the following permissions:

- `ec2:CreateKeyPair`
- `ec2:DescribeKeyPairs`
- `ec2:RunInstances`
- `ec2:DescribeInstances`
- `ec2:CreateSecurityGroup`
- `ec2:AuthorizeSecurityGroupIngress`
- `s3:CreateBucket`
- `s3:PutBucketVersioning`
- `s3:PutBucketPublicAccessBlock`

---

## Setup

### Using a Local Machine

1. Install the AWS CLI:

2. Configure credentials:

Provided the appropriate keys when prompted:
```
AWS Access Key ID:
AWS Secret Access Key:
Default region name:      # e.g. eu-west-1
Default output format:    # json
```

3. Verify identity:

## Execution Steps

### Step 1 — Set up the local environment

### Step 2 — Get the correct AMI ID for your region

### Step 3 — Create a Security Group

### Step 4 — Create EC2 Key Pair and Launch Instance

Upon success, you will see:
```
======================================
  EC2 Instance Ready
======================================
  Instance ID : i-0abc123def456789
  Public IP   : 34.250.XXX.XXX
  Type        : t2.micro
  AMI         : ami-0c13c2049f369d641
  Key File    : my-ec2-keypair.pem
  Tag         : Project=AutomationLab
======================================
```

### Step 5 — Create an S3 Bucket

### Step 6 — View the logs

## Logging

All scripts share a common `log()` function that writes timestamped entries to `logs/aws_setup.log` and prints them to the terminal simultaneously.

Log format:
```
2026-05-18 19:22:17 [INFO]  Instance launched — ID: i-0abc123def456789
2026-05-18 19:22:17 [WARN]  Key pair already exists — skipping
2026-05-18 19:22:17 [ERROR] Failed to connect to endpoint
```

Log levels used:

| Level | Meaning |
|-------|---------|
| `INFO` | Normal operation |
| `WARN` | Non-critical issue, script continues |
| `ERROR` | Critical failure, script exits |

---

## Common Challenges & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `UnauthorizedOperation` | SCP blocking the action | Contact lab admin for permissions |
| `InvalidAMIID.NotFound` | Wrong AMI for region | Re-run the AMI lookup command for your region |
| `InvalidKeyPair.Duplicate` | Key pair already exists | Script skips automatically |
| `BucketAlreadyExists` | S3 bucket name taken | Change bucket name to something unique |
| `aws: command not found` | AWS CLI not installed | Install AWS CLI or use CloudShell |
| Windows line ending issues | Script edited on Windows | Run `sed -i 's/\r//' script.sh` |


**Abulfail Ahmed Rufai** — DevOps Automation Lab, Amalitech Training Program
