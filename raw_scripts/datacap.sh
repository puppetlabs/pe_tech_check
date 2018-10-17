#!/bin/bash

# Sort out variables and housekeeping
master=$(/bin/grep certname /etc/puppetlabs/puppet/puppet.conf | /bin/head -1 | /bin/awk '{print $NF}')
workdir="/var/tmp/hcl_data"
dumpfile="$workdir/datacap_out.txt"
if [ ! -d $workdir ]; then
  /bin/mkdir $workdir
fi

# Get node count
echo "No. of Nodes: $(/bin/curl -sX GET http://localhost:8080/pdb/query/v4 --data-urlencode 'query=nodes[count()]{ node_state = "active" }')" > $dumpfile 2>&1
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
