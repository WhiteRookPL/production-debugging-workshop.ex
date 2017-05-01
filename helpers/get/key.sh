#!/bin/bash

KEY=${1:-bar}
BUCKET=${2:-foo}

curl -i -H "Content-Type: application/json" "http://localhost:8080/buckets/${BUCKET}/keys/${KEY}"