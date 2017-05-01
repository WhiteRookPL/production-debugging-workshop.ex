#!/bin/bash

BUCKET=${1:-"foo"}

curl -i -X POST -H "Content-Type: application/json" "http://localhost:8080/jobs/average/${BUCKET}"