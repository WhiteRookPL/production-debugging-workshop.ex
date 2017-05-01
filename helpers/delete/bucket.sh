#!/bin/bash

BUCKET=${1:-"foo"}

curl -i -X DELETE -H "Content-Type: application/json" "http://localhost:8080/buckets/${BUCKET}"