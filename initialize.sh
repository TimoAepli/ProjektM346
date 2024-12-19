#!/bin/bash

time=$(date +%Y%m%d%H%M%S)
export BUCKET_NAME="csvinput$time"
export BUCKET2_NAME="jsonoutput$time"
export LAMBDA_NAME="CsvToJson"
REGION=$(aws configure get region)
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

if [ -z "$1" ]; then
    export CSV_DELIMITER="Comma"
else
    case "$1" in
        ",")
            export CSV_DELIMITER="comma"
            ;;
        ";")
            export CSV_DELIMITER="semicolon"
            ;;
        "\t")
            export CSV_DELIMITER="tab"
            ;;
        "|")
            export CSV_DELIMITER="pipe"
            ;;
        ":")
            export CSV_DELIMITER="colon"
            ;;
        " ")
            export CSV_DELIMITER="space"
            ;;
        "~")
            export CSV_DELIMITER="tilde"
            ;;
        "^")
            export CSV_DELIMITER="caret"
            ;;
        *)
            echo "Delimiter ist nicht verfügbar"
            exit 1
            ;;
    esac
fi

# export the variables to a temporary environment file
ENV_FILE="./env.sh"
echo "export BUCKET_NAME=$BUCKET_NAME" > "$ENV_FILE"
echo "export BUCKET2_NAME=$BUCKET2_NAME" >> "$ENV_FILE"
echo "export LAMBDA_NAME=$LAMBDA_NAME" >> "$ENV_FILE"

# Create the lambda function
cd CsvToJson/src/CsvToJson
dotnet lambda deploy-function \
    --function-role LabRole \
    $LAMBDA_NAME

# Check if the lambda function was created
if [ $? -eq 0 ]; then
    echo "Lambda Funktion '$LAMBDA_NAME' erfolgreich erstellt."
else
    echo "Lambda Funktion konnte nicht erstellt werden"
fi

aws lambda update-function-configuration --function-name $LAMBDA_NAME --environment "Variables={BUCKET2_NAME=$BUCKET2_NAME,CSV_DELIMITER=$CSV_DELIMITER}"

# Check if the lambda function environment variables were created
if [ $? -eq 0 ]; then
    echo "Umgebungsvariabeln erfolgreich erstellt."
else
    echo "Umgebungsvariabeln konnten nicht erstellt werden"
fi


# Create the s3 bucket
aws s3 mb s3://$BUCKET_NAME

# Check if the bucket was created
if [ $? -eq 0 ]; then
    echo "S3 Bucket '$BUCKET_NAME' erfolgreich erstellt."
else
    echo "S3 Bucket konnte nicht erstellt werden"
fi

# Create the s3 bucket
aws s3 mb s3://$BUCKET2_NAME

# Check if the bucket was created
if [ $? -eq 0 ]; then
    echo "S3 Bucket '$BUCKET2_NAME' erfolgreich erstellt."
else
    echo "S3 Bucket konnte nicht erstellt werden"
fi

# Create the trigger of the lambda function
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

# Check if trigger was created
if [ $? -eq 0 ]; then
    echo "Trigger für Lambda Funktion '$LAMBDA_NAME' erfolgreich erstellt"
else
    echo "Trigger für Lambda Funktion konnte nicht erstellt werden"
fi