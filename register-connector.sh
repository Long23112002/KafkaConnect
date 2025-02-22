#!/bin/bash

BASE_DIR="src/main/java/org/example" 

if [ $# -ne 1 ]; then
    echo "Usage: $0 <relative-path-to-json>"
    exit 1
fi

RELATIVE_PATH="$1"
JSON_FILE="$BASE_DIR/$RELATIVE_PATH"  

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: File '$JSON_FILE' not found!"
    exit 1
fi


CONNECTOR_NAME=$(grep '"name"' "$JSON_FILE" | head -n 1 | sed -E 's/.*"name": *"([^"]+)".*/\1/')

if [ -z "$CONNECTOR_NAME" ]; then
    echo "Error: Could not extract connector name from JSON file!"
    exit 1
fi

EXISTING_CONNECTORS=$(curl -s http://localhost:8083/connectors)

if echo "$EXISTING_CONNECTORS" | grep -q "\"$CONNECTOR_NAME\""; then
    echo "Connector '$CONNECTOR_NAME' already exists. Updating..."
    curl -X PUT http://localhost:8083/connectors/$CONNECTOR_NAME/config \
         -H "Content-Type: application/json" \
         -d @"$JSON_FILE"
else
    echo "Creating new connector: $CONNECTOR_NAME..."
    curl -X POST http://localhost:8083/connectors \
         -H "Content-Type: application/json" \
         -d @"$JSON_FILE"
fi

echo "Done!"
