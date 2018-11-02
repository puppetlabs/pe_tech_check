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
# Master
master=$(/bin/grep certname /etc/puppetlabs/puppet/puppet.conf | /bin/head -1 | /bin/awk '{print $NF}')
# PuppetDB
puppetdb=$(/bin/grep '^.*[^#]"puppet_enterprise::puppetdb_host"' /etc/puppetlabs/enterprise/conf.d/pe.conf | /bin/awk --field-separator=: '{print $NF}' | /bin/sed 's/\"//g')
if [ -z $puppetdb ]; then
  puppetdb=$master
fi
# Console
console=$(/bin/grep '^.*[^#]"puppet_enterprise::console_host"' /etc/puppetlabs/enterprise/conf.d/pe.conf | /bin/awk --field-separator=: '{print $NF}' | /bin/sed 's/\"//g')
if [ -z $console ]; then
  console=$master
fi

workdir="/var/tmp/hcl_data"
dumpfile="$workdir/datacap_out.txt"
if [ ! -d $workdir ]; then
  /bin/mkdir $workdir
fi

# Start Script logic
echo "Starting data capture..."
echo "Run start: $(/bin/date)" > $dumpfile 2>&1
echo "Master/MoM node is $master" >> $dumpfile 2>&1
echo "PuppetDB node is $puppetdb" >> $dumpfile 2>&1
echo "Console Node is $console" >> $dumpfile 2>&1
echo "" >> $dumpfile 2>&1

# Get PE version
echo "PE version: $(/usr/local/bin/facter -p pe_server_version)" >> $dumpfile 2>&1

# Get node count
echo "No. of Nodes: $(/bin/curl -sX GET https://$puppetdb:8081/pdb/query/v4 \
--cert /etc/puppetlabs/puppet/ssl/certs/$master.pem \
--key /etc/puppetlabs/puppet/ssl/private_keys/$master.pem \
--cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem \
--data-urlencode 'query=nodes[count()]{ node_state = "active" }')" >> $dumpfile 2>&1
echo "" >> $dumpfile 2>&1



# Get Number of environments
echo "No of environments: $(/bin/ls /etc/puppetlabs/code/environments/ | wc -l)" >> $dumpfile 2>&1
# Get no of modules in Production environment
echo "No of modules in Production environment: $(/bin/ls /etc/puppetlabs/code/environments/production/modules/ | wc -l)" >> $dumpfile 2>&1
# Get code directory size
echo "Code directory size: $(/bin/du -sh /etc/puppetlabs/code)" >> $dumpfile 2>&1
echo "" >> $dumpfile 2>&1

# Get license data
echo "License Info:" >> $dumpfile 2>&1
/bin/cat /etc/puppetlabs/license.key >> $dumpfile 2>&1

# Check for HA Setup
echo "Puppet Infrastructure Status Output:" >> $dumpfile 2>&1
/opt/puppetlabs/bin/puppet-infrastructure status >> $dumpfile 2>&1

# Classification and Hiera customization dump
echo "Classification customisations for Master nodes (MoM and CMs)" >> $dumpfile 2>&1
/bin/curl -sX GET https://$puppetdb:8081/pdb/query/v4 \
--cert /etc/puppetlabs/puppet/ssl/certs/$master.pem \
--key /etc/puppetlabs/puppet/ssl/private_keys/$master.pem \
--cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem \
--data-urlencode 'query=resources[certname, parameters]{type="Class" and title="Puppet_enterprise::Profile::Master"}' \
| python -m json.tool >> $dumpfile 2>&1
echo "" >> $dumpfile 2>&1
echo "Classification customisations for PuppetDB node" >> $dumpfile 2>&1
/bin/curl -sX GET https://$puppetdb:8081/pdb/query/v4 \
--cert /etc/puppetlabs/puppet/ssl/certs/$master.pem \
--key /etc/puppetlabs/puppet/ssl/private_keys/$master.pem \
--cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem \
--data-urlencode 'query=resources[certname, parameters]{type="Class" and title="Puppet_enterprise::Profile::Puppetdb"}' \
| python -m json.tool >> $dumpfile 2>&1
echo "" >> $dumpfile 2>&1
echo "Classification customisations for Console node" >> $dumpfile 2>&1
/bin/curl -sX GET https://$puppetdb:8081/pdb/query/v4 \
--cert /etc/puppetlabs/puppet/ssl/certs/$master.pem \
--key /etc/puppetlabs/puppet/ssl/private_keys/$master.pem \
--cacert /etc/puppetlabs/puppet/ssl/certs/ca.pem \
--data-urlencode 'query=resources[certname, parameters]{type="Class" and title="Puppet_enterprise::Profile::Console"}' \
| python -m json.tool >> $dumpfile 2>&1
echo "" >> $dumpfile 2>&1


# Get output of tuning script if version is greater than PE2018
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
  /opt/puppetlabs/bin/puppet-metrics-collector create-tarball >> $dumpfile 2>&1
else
  echo "Metrics Module not installed or not enabled" >> $dumpfile 2>&1
fi

echo "Data collected to $dumpfile"
