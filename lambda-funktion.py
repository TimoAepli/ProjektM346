import boto3
import csv
import json
import os
from urllib.parse import unquote_plus
 
def lambda_handler(event, context):
    """
    Lambda function to convert a CSV file to a JSON file when a new CSV file is uploaded to an S3 bucket.
 
    Args:
        event: Event data (S3 trigger)
        context: Runtime information
 
    Returns:
        dict: Status of the operation
    """
    # Initialize S3 client
    s3_client = boto3.client('s3')
 
    try:
        # Get bucket name and file key from the event
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        csv_file_key = unquote_plus(event['Records'][0]['s3']['object']['key'])
 
        # Download the CSV file from S3
        download_path = f"/tmp/{os.path.basename(csv_file_key)}"
        s3_client.download_file(bucket_name, csv_file_key, download_path)
 
        # Convert CSV to JSON
        json_content = convert_csv_to_json(download_path)
 
        # Upload JSON file back to S3
        json_file_key = csv_file_key.rsplit('.', 1)[0] + '.json'
        upload_path = f"/tmp/{os.path.basename(json_file_key)}"
 
        with open(upload_path, 'w') as json_file:
            json.dump(json_content, json_file, indent=4)
 
        s3_client.upload_file(upload_path, bucket_name, json_file_key)
 
        return {
            'statusCode': 200,
            'body': json.dumps(f"Successfully converted {csv_file_key} to {json_file_key}")
        }
 
    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error processing file {csv_file_key}: {str(e)}")
        }
 
def convert_csv_to_json(file_path):
    """
    Converts a CSV file to a list of JSON objects.
 
    Args:
        file_path (str): Path to the CSV file
 
    Returns:
        list: List of JSON objects representing rows in the CSV file
    """
    with open(file_path, 'r') as csv_file:
        reader = csv.DictReader(csv_file)
        return [row for row in reader]