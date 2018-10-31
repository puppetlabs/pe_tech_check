#!/bin/sh

# Define hostname and other variables
nodename=$(/bin/hostname -f)
workdir="/var/tmp/hcl_data"

# Run Data Capture Task
/opt/puppetlabs/bin/puppet-task run healthcheck_lite::datacapture --token-file=$workdir/token --nodes $nodename

# Run Data Package Task
/opt/puppetlabs/bin/puppet-task run healthcheck_lite::packagedata identifier=$PT_identifier --token-file=$workdir/token --nodes $nodename
