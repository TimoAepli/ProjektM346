#!/bin/bash

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