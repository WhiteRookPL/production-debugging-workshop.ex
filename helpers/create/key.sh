#!/bin/bash

KEY=${1:-"bar"}
VALUE=${2:-"test value"}
BUCKET=${3:-"foo"}

curl -i -X POST -H "Content-Type: application/json" -d "{\"key\": \"${KEY}\", \"value\":\"${VALUE}\"}" "http://localhost:8080/buckets/${BUCKET}/keys"