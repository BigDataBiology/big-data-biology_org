#!/usr/bin/env bash

set -e
jekyll b
python fix-mtimes.py
aws s3 sync --region eu-west-1 _site s3://big-data-biology.org/
