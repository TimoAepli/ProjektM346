#!/bin/bash

# check if enviroment file exists
if [ -f ./env.sh ]; then
  source ./env.sh
else
  echo "Fehler: env.sh konnte nicht gefunden werden, bitte zuerst initialize.sh ausführen"
  exit 1
fi

if [ -z "$1" ]; then
    read -p "Bitte Pfad zu csv-Datei eingeben: " input
else
    input=$1
fi

if [ ! -f "$input" ]; then
    echo "$input existiert nicht"
    exit 1
fi

csv_file=$(basename "$input")
json_file="${csv_file%.csv}.json"

# Upload content to the bucket
aws s3 cp $input s3://$BUCKET_NAME

# Check if the file was uploaded
if [ $? -eq 0 ]; then
    echo "Datei $input erfolgreich hochgeladen."
else
    echo "Datei $input konnte nicht hochgeladen werden"
fi

sleep 3

# Download the JSON file from the S3 bucket
aws s3 cp "s3://$BUCKET2_NAME/$json_file" "./$json_file"

# Check if the download was successful
if [ $? -eq 0 ]; then
    echo "Datei $json_file erfolgreich heruntergeladen und in der Datei $json_file gespeichert."
else
    echo "Datei $json_file konnte nicht heruntergeladen werden."
fi