#!/bin/bash

ID=${1:-"1"}

curl -i -H "Content-Type: application/json" "http://localhost:8080/jobs/${ID}"