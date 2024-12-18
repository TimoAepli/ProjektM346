using Amazon.Lambda.Core;
using Amazon.Lambda.S3Events;
using Amazon.S3;
using Amazon.S3.Model;
using CsvHelper;
using System.Globalization;
using System.IO;
using System.Text.Json;

// Assembly attribute to enable the Lambda function's JSON input to be converted into a .NET class.
[assembly: LambdaSerializer(typeof(Amazon.Lambda.Serialization.SystemTextJson.DefaultLambdaJsonSerializer))]

namespace CsvToJson
{
    public class Function
    {
        private readonly IAmazonS3 _s3Client;

        public Function()
        {
            _s3Client = new AmazonS3Client();
        }

        public async Task FunctionHandler(S3Event s3Event, ILambdaContext context)
        {
            var TargetBucket = Environment.GetEnvironmentVariable("BUCKET2_NAME");            
            foreach (var record in s3Event.Records)
            {
                string sourceBucket = record.S3.Bucket.Name;
                string key = record.S3.Object.Key;

                try
                {
                    // Get the CSV file from the source bucket
                    GetObjectResponse response = await _s3Client.GetObjectAsync(sourceBucket, key);

                    using (var reader = new StreamReader(response.ResponseStream))
                    using (var csv = new CsvReader(reader, CultureInfo.InvariantCulture))
                    {
                        // Read CSV and convert to JSON
                        var records = csv.GetRecords<dynamic>();
                        string json = JsonSerializer.Serialize(records, new JsonSerializerOptions { WriteIndented = true });

                        // Write JSON to the target bucket
                        var putRequest = new PutObjectRequest
                        {
                            BucketName = TargetBucket,
                            Key = $"{Path.GetFileNameWithoutExtension(key)}.json",
                            ContentType = "application/json",
                            ContentBody = json
                        };

                        await _s3Client.PutObjectAsync(putRequest);

                        context.Logger.LogLine($"Converted CSV to JSON and uploaded to {TargetBucket}");
                    }
                }
                catch (Exception ex)
                {
                    context.Logger.LogLine($"Error processing file {key} from bucket {sourceBucket}: {ex.Message}");
                    throw;
                }
            }
        }
    }
}
