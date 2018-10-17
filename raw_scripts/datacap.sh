#!/bin/bash

################################################################################
# This script collects additional material which is required for carrying out  #
# a basic healthcheck of the Puppet Enterprise Infrastructure nodes.           #
# It is designed to be run as a Task from a specially created module, along    #
# with a number of other Tasks to collect the entire body of data.             #
################################################################################
# Copyright 2018, Puppet, Inc.                                                 #
# support@puppet.com                                                           #
################################################################################

# Sort out variables and housekeeping
master=$(/bin/grep certname /etc/puppetlabs/puppet/puppet.conf | /bin/head -1 | /bin/awk '{print $NF}')
workdir="/var/tmp/hcl_data"
dumpfile="$workdir/datacap_out.txt"
if [ ! -d $workdir ]; then
  /bin/mkdir $workdir
fi

# Start Script logic
echo "Starting data capture..."
echo "Run start: $(/bin/date)" > $dumpfile 2>&1
echo "" >> $dumpfile 2>&1

# Get node count (assumes monolithic)
echo "No. of Nodes: $(/bin/curl -sX GET http://localhost:8080/pdb/query/v4 --data-urlencode 'query=nodes[count()]{ node_state = "active" }')" >> $dumpfile 2>&1
echo "" >> $dumpfile 2>&1

# Get Number of environments
echo "No of environments: $(/bin/ls /etc/puppetlabs/code/environments/ | wc -l)" >> $dumpfile 2>&1
# Get no of modules in Production environment
echo "No of modules in Production environment: $(/bin/ls /etc/puppetlabs/code/environments/production/modules/ | wc -l)" >> $dumpfile 2>&1
# Get code directory size
echo "Code directory size: $(/bin/du -sh /etc/puppetlabs/code)" >> $dumpfile 2>&1
echo "" >> $dumpfile 2>&1

# Classification dump
echo "Classification for $master" >> $dumpfile 2>&1
/bin/curl -sX POST https://$master:4433/classifier-api/v1/classified/nodes/$master \
		--cert /etc/puppetlabs/puppet/ssl/certs/$master.pem \
		--key /etc/puppetlabs/puppet/ssl/private_keys/$master.pem \
		--cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem -H "Content-Type: application/json" \
    | /bin/python -m json.tool >> $dumpfile 2>&1
echo "" >> $dumpfile 2>&1

# Get output of tuning script if version is greater than PE20128
if [ "$(/opt/puppetlabs/puppet/bin/facter -p pe_build | /bin/awk --field-separator=. '{print $1}')" -gt '2017' ]; then
  echo "PE version greater than PE 2017.3.z, running Tuning Script for current settings..." >> $dumpfile 2>&1
	/opt/puppetlabs/server/apps/enterprise/bin/puppet-infrastructure tune --force --current >> $dumpfile 2>&1
	echo "" >> $dumpfile 2>&1
	echo "Running Tuning Script to get recommended values..." >> $dumpfile 2>&1
	/opt/puppetlabs/server/apps/enterprise/bin/puppet-infrastructure tune --force >> $dumpfile 2>&1
	echo "" >> $dumpfile 2>&1
else
	echo "PE version below PE 2018.0.0, no Tuning Script available" >> $dumpfile 2>&1
	echo "" >> $dumpfile 2>&1
fi

# Get metrics if module installed
if [ -d /opt/puppetlabs/puppet-metrics-collector ]; then
  cd $workdir
  echo "Metrics tarball created" >> $dumpfile 2>&1
  /opt/puppetlabs/bin/puppet-metrics-collector create-tarball >> $dumpfile 2>&1
fi

echo "Data collected to $dumpfile"
