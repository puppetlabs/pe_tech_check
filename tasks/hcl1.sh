#!/bin/bash

# Define hostname and other variables
nodename=$(/bin/hostname -f)
login=$PT_login
password=$PT_password

# Create curl query
token_query="{\"login\": \""$login"\", \"password\": \""$password"\", \"lifetime\": \"1d\", \"label\": \"Healthcheck Lite token\"}"

# Create data aggregation directory
workdir="/var/tmp/hcl_data"
if [ ! -d $workdir ]; then
  /bin/mkdir $workdir
fi

/bin/echo $(/bin/curl -s -k -X POST -H 'Content-Type: application/json' -d "$token_query" https://$nodename:4433/rbac-api/v1/auth/token | /bin/awk --field-separator=\" '{print $4}') > $workdir/token



# Run Support Script Capture Task on all infrastructure nodes
/opt/puppetlabs/bin/puppet-task run --query 'resources[certname] { (type = "Class" and title = "Puppet_enterprise::Profile::Master") or (type = "Class" and title = "Puppet_enterprise::Profile::Puppetdb") or (type = "Class" and title = "Puppet_enterprise::Profile::Console") }' healthcheck_lite::supportcapture --token-file=$workdir/token
