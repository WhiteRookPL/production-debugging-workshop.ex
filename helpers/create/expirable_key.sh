#!/bin/bash

KEY=${1:-"bar"}
VALUE=${2:-"test value"}
TTL=${3:-5000}
BUCKET=${4:-"foo"}

curl -i -X POST -H "Content-Type: application/json" -d "{\"key\": \"${KEY}\", \"value\":\"${VALUE}\", \"ttl\": \"${TTL}\"}" "http://localhost:8080/buckets/${BUCKET}/keys"