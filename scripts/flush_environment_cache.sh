#!/bin/bash
# Flushes the environment cache
#
function curl_wrapper()
{
  [ "$g_verbose" = 'true' ] && echo "command: curl $@"
  output=$(curl "$@")
  exitcode=$?
  if [ "$g_verbose" = 'true' ]; then
    echo "output json:"
    echo "$output" | python -m json.tool || echo "raw output: $output"
    echo "exitcode: $exitcode"
    echo
  fi
}

g_verbose='true'
g_certname=$(/opt/puppetlabs/bin/puppet config print certname --section agent)

curl_wrapper -ks --request DELETE --header "Content-Type: application/json" \
    --cert "/etc/puppetlabs/puppet/ssl/certs/${g_certname}.pem" \
    --key "/etc/puppetlabs/puppet/ssl/private_keys/${g_certname}.pem" \
    --cacert "/etc/puppetlabs/puppet/ssl/certs/ca.pem" \
    'https://localhost:8140/puppet-admin-api/v1/environment-cache'


