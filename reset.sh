#!/bin/bash

# check if enviroment file exists
if [ -f ./env.sh ]; then
  source ./env.sh
else
  echo "Fehler: env.sh konnte nicht gefunden werden, bitte zuerst initialize.sh ausführen"
  exit 1
fi

# Remove content of the buckets
aws s3 rm s3://$BUCKET_NAME --recursive
aws s3 rm s3://$BUCKET2_NAME --recursive


# Delete the bucket
aws s3 rb s3://$BUCKET_NAME

#  if the bucket was deleted
if [ $? -eq 0 ]; then
    echo "S3 Bucket '$BUCKET_NAME' erfolgreich gelöscht."
else
    echo "S3 Bucket konnte nicht gelöscht werden"
fi

# Delete the bucket
aws s3 rb s3://$BUCKET2_NAME

# Check if the bucket was deleted
if [ $? -eq 0 ]; then
    echo "S3 Bucket '$BUCKET2_NAME' erfolgreich gelöscht."
else
    echo "S3 Bucket konnte nicht gelöscht werden"
fi

# Delete permission
aws lambda remove-permission \
    --function-name $LAMBDA_NAME \
    --statement-id S3InvokePermission

# Check if permission was deleted
if [ $? -eq 0 ]; then
    echo "permission erfolgreich gelöscht."
else
    echo "permission konnte nicht gelöscht werden"
fi    

# Delete the lambda function
aws lambda delete-function --function-name $LAMBDA_NAME

# Check if the lambda function was deleted
if [ $? -eq 0 ]; then
    echo "Lambda Funktion '$LAMBDA_NAME' erfolgreich gelöscht."
else
    echo "Lambda Funktion konnte nicht gelöscht werden"
fi

# delet environment file
rm ./env.sh

echo "env.sh erfolgreich gelöscht"