#!/bin/bash

fetch_secrets() {
    SECRET_NAME=$1
    OUTPUT_FILE=$2

    echo "Fetching secrets for: $SECRET_NAME"

    # Get the secret value
    SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query 'SecretString' --output text)

    if [ $? -ne 0 ]; then
        echo "Error fetching secret: $SECRET_NAME"
        exit 1
    fi

    echo $SECRET_VALUE | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' >> $OUTPUT_FILE

    if [ $? -ne 0 ]; then
        echo "Error writing to file: $OUTPUT_FILE"
        exit 1
    fi

    echo "Secrets for $SECRET_NAME written to $OUTPUT_FILE"
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 SECRET_NAME OUTPUT_FILE"
    exit 1
fi

SECRET_NAME=$1
OUTPUT_FILE=$2

if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install jq to proceed."
    exit 1
fi

fetch_secrets $SECRET_NAME $OUTPUT_FILE

