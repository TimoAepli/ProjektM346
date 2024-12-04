#!/bin/bash
sudo apt-get update
sudo apt-get -y install python3-pip
sudo apt-get -y install awscli
pip install boto3

# Beispielhafte Verarbeitung einer CSV-Datei zu JSON
IN_BUCKET="csv-input-bucket"
OUT_BUCKET="json-output-bucket"
aws s3 cp s3://$IN_BUCKET/sample.csv sample.csv
python3 -c "import csv, json; 
with open('sample.csv') as csv_file, open('sample.json', 'w') as json_file:
    reader = csv.DictReader(csv_file)
    json.dump(list(reader), json_file)"
aws s3 cp sample.json s3://$OUT_BUCKET/sample.json
