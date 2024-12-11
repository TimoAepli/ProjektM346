#!/bin/bash

# Variables
FUNCTION_NAME="lambda-function"             # Replace with your Lambda function's name
ZIP_FILE="lambda.zip"                       # The zip file containing your Lambda code
HANDLER="lambda_function.lambda_handler"    # Replace with your handler function
RUNTIME="python3.9"                         # Replace with your runtime (e.g., nodejs18.x, python3.9)
 
# Check if the Lambda function already exists
EXISTS=$(aws lambda get-function --function-name "$FUNCTION_NAME" 2>/dev/null)
 
if [ -z "$EXISTS" ]; then
    echo "Creating new Lambda function: $FUNCTION_NAME"
    aws lambda create-function \
        --function-name "$FUNCTION_NAME" \
        --runtime "$RUNTIME" \
        --role "LabRole" \
        --handler "$HANDLER" \
        --zip-file "fileb://$ZIP_FILE" 
else
    echo "Updating existing Lambda function: $FUNCTION_NAME"
    aws lambda update-function-code \
        --function-name "$FUNCTION_NAME" \
        --zip-file "fileb://$ZIP_FILE" 
fi

aws s3 mb s3://m3461234567890

# Check if the bucket was created
if [ $? -eq 0 ]; then
    echo "S3 Bucket 'm3461234567890' erfolgreich erstellt."
else
    echo "S3 Bucket konnte nicht erstellt werden"
fi

# Upload content to the bucket
aws s3 cp ~/test.csv s3://m3461234567890

# Check if the file was uploaded
if [ $? -eq 0 ]; then
    echo "Datei erfolgreich hochgeladen."
else
    echo "Datei konnte nicht hochgeladen werden"
fi
 
# Remove content of the bucket
aws s3 rm s3://m3461234567890 --recursive

# Delete the bucket
aws s3 rb s3://m3461234567890

# Check if the bucket was deleted
if [ $? -eq 0 ]; then
    echo "S3 Bucket 'm3461234567890' erfolgreich gelöscht."
else
    echo "S3 Bucket konnte nicht gelöscht werden"
fi