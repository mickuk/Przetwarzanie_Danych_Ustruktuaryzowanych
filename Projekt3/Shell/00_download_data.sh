#!/bin/sh

# You can install the latest version of AWS CLI at:
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
aws s3 sync --no-sign-request s3://tripdata Data \
            --exclude "*" --include "JC*"

unzip "Data/*.csv.zip" -d Data
rm -r Data/*.csv.zip Data/__MACOSX
