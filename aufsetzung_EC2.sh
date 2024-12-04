#!/bin/bash

echo "### Starte die Provisionierung des CSV-zu-JSON-Konvertierungsdienstes ###"

# 1. Schlüsselpaar erstellen (falls nicht vorhanden)
if [ ! -f ~/.ssh/csv2json-key.pem ]; then
    echo "Erstelle Schlüsselpaar..."
    aws ec2 create-key-pair \
    --key-name csv2json-key \
    --key-type rsa \
    --query 'KeyMaterial' \
    --output text > ~/.ssh/csv2json-key.pem
    chmod 400 ~/.ssh/csv2json-key.pem
else
    echo "Schlüsselpaar existiert bereits."
fi

# 2. Sicherheitsgruppe erstellen (falls nicht vorhanden)
SEC_GROUP_NAME="csv2json-sec-group"
if ! aws ec2 describe-security-groups --group-names $SEC_GROUP_NAME > /dev/null 2>&1; then
    echo "Erstelle Sicherheitsgruppe..."
    aws ec2 create-security-group \
    --group-name $SEC_GROUP_NAME \
    --description "CSV-zu-JSON Konvertierungsdienst"
    aws ec2 authorize-security-group-ingress \
    --group-name $SEC_GROUP_NAME \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0
    aws ec2 authorize-security-group-ingress \
    --group-name $SEC_GROUP_NAME \
    --protocol tcp \
    --port 22 \
    --cidr 0.0.0.0/0
else
    echo "Sicherheitsgruppe existiert bereits."
fi

# 3. Passwort im Secrets Manager speichern (falls nicht vorhanden)
SECRET_NAME="Csv2JsonServicePassword"
if ! aws secretsmanager describe-secret --secret-id $SECRET_NAME > /dev/null 2>&1; then
    echo "Speichere Passwort im Secrets Manager..."
    aws secretsmanager create-secret \
    --name $SECRET_NAME \
    --secret-string "superSecurePassword"
else
    echo "Passwort existiert bereits im Secrets Manager."
fi

# 4. Init-Skript für EC2 erstellen
echo "Erstelle Initialisierungsskript..."
cat << 'EOF' > csv2json-init.sh
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
EOF
chmod +x csv2json-init.sh

# 5. EC2-Instanz starten
echo "Starte EC2-Instanz..."
EC2_INSTANCE_ID=$(aws ec2 run-instances \
--image-id ami-08c40ec9ead489470 \
--count 1 \
--instance-type t2.micro \
--key-name csv2json-key \
--security-groups $SEC_GROUP_NAME \
--user-data file://csv2json-init.sh \
--query 'Instances[*].InstanceId' \
--output text)

echo "EC2-Instanz gestartet mit ID: $EC2_INSTANCE_ID"

# 6. Warten, bis Instanz bereit ist
echo "Warte, bis Server bereit ist..."
while :; do
    EC2_PUBLIC_IP=$(aws ec2 describe-instances \
    --filters Name=instance-id,Values=$EC2_INSTANCE_ID \
    --query 'Reservations[*].Instances[*].[PublicIpAddress]' \
    --output text)
    
    if [ "$EC2_PUBLIC_IP" != "None" ]; then
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://$EC2_PUBLIC_IP:5000/neptune)
        if [ "$HTTP_STATUS" -eq 200 ]; then
            echo "Server ist bereit: http://$EC2_PUBLIC_IP:5000/neptune"
            break
        fi
    fi
    sleep 10
done

echo "### Bereitstellung abgeschlossen ###"
