#!/bin/bash

BUCKET_NAME="m3461234567890"
BUCKET2_NAME="m3460987654321"
LAMBDA_NAME="CsvToJson"
REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

cd CsvToJson/src/CsvToJson
dotnet lambda deploy-function --function-role LabRole $LAMBDA_NAME

if [ $? -eq 0 ]; then
    echo "Lambda Funktion '$LAMBDA_NAME' erfolgreich erstellt."
else
    echo "Lambda Funktion konnte nicht erstellt werden"
fi

aws s3 mb s3://$BUCKET_NAME

# Check if the bucket was created
if [ $? -eq 0 ]; then
    echo "S3 Bucket '$BUCKET_NAME' erfolgreich erstellt."
else
    echo "S3 Bucket konnte nicht erstellt werden"
fi

aws s3 mb s3://$BUCKET2_NAME

# Check if the bucket was created
if [ $? -eq 0 ]; then
    echo "S3 Bucket '$BUCKET2_NAME' erfolgreich erstellt."
else
    echo "S3 Bucket konnte nicht erstellt werden"
fi

aws lambda add-permission \
    --function-name $LAMBDA_NAME \
    --statement-id S3InvokePermission \
    --action "lambda:InvokeFunction" \
    --principal s3.amazonaws.com \
    --source-arn "arn:aws:s3:::$BUCKET_NAME"

aws s3api put-bucket-notification-configuration \
    --bucket $BUCKET_NAME \
    --notification-configuration "{
        \"LambdaFunctionConfigurations\": [
            {
                \"LambdaFunctionArn\": \"arn:aws:lambda:$REGION:$ACCOUNT_ID:function:$LAMBDA_NAME\",
                \"Events\": [\"s3:ObjectCreated:*\"],
                \"Filter\": {
                    \"Key\": {
                        \"FilterRules\": [
                            { \"Name\": \"suffix\", \"Value\": \".csv\" }
                        ]
                    }
                }
            }
        ]
    }"

if [ $? -eq 0 ]; then
    echo "Trigger für Lambda Funktion '$LAMBDA_NAME' erfolgreich erstellt"
else
    echo "Trigger für Lambda Funktion konnte nicht erstellt werden"
fi

# Upload content to the bucket
aws s3 cp ~/test.csv s3://$BUCKET_NAME

# Check if the file was uploaded
if [ $? -eq 0 ]; then
    echo "Datei erfolgreich hochgeladen."
else
    echo "Datei konnte nicht hochgeladen werden"
fi

# Remove content of the bucket
#aws s3 rm s3://$BUCKET_NAME --recursive

# Delete the bucket
#aws s3 rb s3://$BUCKET_NAME

# Check if the bucket was deleted
# if [ $? -eq 0 ]; then
#     echo "S3 Bucket '$BUCKET_NAME' erfolgreich gelöscht."
# else
#     echo "S3 Bucket konnte nicht gelöscht werden"
# fi