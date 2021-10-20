#!/bin/bash
# shellcheck disable=SC2145
#
# Flushes the environment cache
#
function curl_wrapper()
{
  echo "command: curl $@"
  curl "$@"
  exitcode=$?
  echo "exitcode: $exitcode"
}

g_certname=$(/opt/puppetlabs/bin/puppet config print certname --section agent)

curl_wrapper -ks --request DELETE --header "Content-Type: application/json" \
    --cert "/etc/puppetlabs/puppet/ssl/certs/${g_certname}.pem" \
    --key "/etc/puppetlabs/puppet/ssl/private_keys/${g_certname}.pem" \
    --cacert "/etc/puppetlabs/puppet/ssl/certs/ca.pem" \
    'https://localhost:8140/puppet-admin-api/v1/environment-cache'


