#!/bin/bash

# Accept unique identifier as parameter
identifier=$PT_identifier
datestamp=$(/bin/date +%d%m%Y)
filename="hcl_"$identifier"_"$datestamp".tar"

echo "Starting packaging of data..."
cd /var/temp
/bin/tar -cvf $filename hcl_data/*
echo "Data tarball created at /var/tmp/$filename."
echo "Please make the tarball at /var/tmp/$filename available to Puppet."
