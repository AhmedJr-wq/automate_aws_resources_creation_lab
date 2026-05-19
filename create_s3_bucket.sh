#!/bin/bash

set -euo pipefail

REGION="eu-west-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
BUCKET_NAME="devops-bucket-${ACCOUNT_ID}-$(date +%s)"
SAMPLE_FILE="welcome.txt"

#Create the S3 Bucket
echo "Creating S3 bucket: $BUCKET_NAME"

if [ "$REGION" == "us-east-1" ]; then
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION"
else
  aws s3api create-bucket \
    --bucket "$BUCKET_NAME" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
fi

echo "Bucket created: $BUCKET_NAME"

#Enable Versioning
echo "Enabling versioning..."

aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

echo "Versioning enabled."

#Apply Bucket Policy
echo "Applying bucket policy..."

#Policy: Allow only the current AWS account to access the bucket
BUCKET_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAccountAccessOnly",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${ACCOUNT_ID}:root"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${BUCKET_NAME}",
        "arn:aws:s3:::${BUCKET_NAME}/*"
      ]
    }
  ]
}
EOF
)

aws s3api put-bucket-policy \
  --bucket "$BUCKET_NAME" \
  --policy "$BUCKET_POLICY"

echo "Bucket policy applied."

#Create & Upload Sample File
echo "Creating and uploading '$SAMPLE_FILE'"

cat <<EOF > "$SAMPLE_FILE"
Welcome to $BUCKET_NAME!
========================
Created on : $(date)
Region     : $REGION
Account    : $ACCOUNT_ID
Versioning : Enabled

This file was automatically uploaded by create_s3_bucket.sh
EOF

aws s3 cp "$SAMPLE_FILE" "s3://$BUCKET_NAME/$SAMPLE_FILE"

echo "File '$SAMPLE_FILE' uploaded successfully."

echo "Done!"