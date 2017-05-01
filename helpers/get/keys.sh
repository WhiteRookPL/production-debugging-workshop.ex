#!/bin/bash

BUCKET=${1:-foo}

curl -i -H "Content-Type: application/json" "http://localhost:8080/buckets/${BUCKET}/keys"