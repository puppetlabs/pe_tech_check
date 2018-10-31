#!/bin/bash

# Accept unique identifier as parameter
identifier=$PT_identifier
datestamp=$(/bin/date +%d%m%Y)
filename="hcl_"$identifier"_"$datestamp".tar"

echo "Starting packaging of data..."

/bin/rm -f /var/tmp/hcl_data/token
/bin/tar -cvf /var/tmp/$filename /var/tmp/hcl_data/*
/bin/rm -rf /var/tmp/hcl_data
echo "Data tarball created at /var/tmp/$filename."
echo "Please make the tarball at /var/tmp/$filename available to Puppet."
