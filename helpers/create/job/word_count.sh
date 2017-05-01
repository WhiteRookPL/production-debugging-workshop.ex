#!/bin/bash

KEY=${1:-"bar"}
BUCKET=${2:-"foo"}

curl -i -X POST -H "Content-Type: application/json" "http://localhost:8080/jobs/wordcount/${BUCKET}/${KEY}"