#!/bin/bash

# Function to fetch and write secret values to a file
fetch_secrets() {
    SECRET_NAME=$1
    OUTPUT_FILE=$2

    echo "Fetching secrets for: $SECRET_NAME"

    # Get the secret value
    SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id $SECRET_NAME --query 'SecretString' --output text)

    # Check if the secret value was retrieved
    if [ $? -ne 0 ]; then
        echo "Error fetching secret: $SECRET_NAME"
        exit 1
    fi

    # Parse the JSON secret string and write key/value pairs to the output file
    echo $SECRET_VALUE | jq -r 'to_entries | .[] | "\(.key)=\(.value)"' >> $OUTPUT_FILE

    # Check if the file writing was successful
    if [ $? -ne 0 ]; then
        echo "Error writing to file: $OUTPUT_FILE"
        exit 1
    fi

    echo "Secrets for $SECRET_NAME written to $OUTPUT_FILE"
}

# Main script starts here
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 SECRET_NAME OUTPUT_FILE"
    exit 1
fi
# Define your secret name and output file
SECRET_NAME=$1
OUTPUT_FILE=$2

# Check if jq is installed (jq is used to parse JSON)
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install jq to proceed."
    exit 1
fi

# Call the function to fetch secrets and write to file
fetch_secrets $SECRET_NAME $OUTPUT_FILE

