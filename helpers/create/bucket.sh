#!/bin/bash

BUCKET=${1:-"foo"}

curl -i -X POST -H "Content-Type: application/json" -d "{\"bucket\": \"${BUCKET}\"}" "http://localhost:8080/buckets"