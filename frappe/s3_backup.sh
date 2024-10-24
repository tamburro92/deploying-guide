#!/bin/bash

FRAPPE_DIR=/home/ubuntu/frappe-14/
BACKUP_DIR=/home/ubuntu/backups_s3/
S3_BUCKET=s3://bucket-s3/
REGION=eu-south-1
###

NOW="$(date +'%Y-%m-%d')"
cd $FRAPPE_DIR
bench --site all backup --with-files --compress --backup-path $BACKUP_DIR$NOW
aws s3 cp  $BACKUP_DIR $S3_BUCKET --recursive --region $REGION
rm -rf $BACKUP_DIR/*