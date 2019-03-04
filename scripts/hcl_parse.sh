#!/bin/bash

# Execute this command from within the extracted 'puppet enterprise support' archive directory.

function echo_code_block() {
  echo "```"
}

echo
echo "## Puppet Enterprise Version"
echo

echo_code_block
grep pe_server_version system/facter_output.json
echo_code_block

echo
echo "## Puppet Infrastructure Status"
echo

echo_code_block
cat enterprise/pe_infra_status.json
echo_code_block

echo
echo "## Active Node Count"
echo

echo_code_block
grep certname enterprise/puppetdb_nodes.json | wc -l
echo_code_block

echo
echo "## Environment Count"
echo

echo_code_block
grep environment_timeout enterprise/puppetserver_environments.json | wc -l
echo_code_block

echo
echo "## Module Count in Production Environment"
echo

pushd enterprise/find && gunzip --force _etc_puppetlabs.txt.gz && popd
egrep '/etc/puppetlabs/code/environments/production/modules/[a-z][a-z0-9_]*$' enterprise/find/_etc_puppetlabs.txt | wc -l

echo
echo "## Module Issues"
echo

echo
echo "### Warnings"
echo

echo_code_block
grep '## Warning' enterprise/modules.txt
echo_code_block

echo
echo "### Errors"
echo

echo_code_block
grep '???' enterprise/modules.txt
echo_code_block

echo
echo "## Missing or Varying hiera-eyaml Gems"
echo

echo_code_block
grep eyaml enterprise/puppet_gems.txt enterprise/puppetserver_gems.txt
echo_code_block

echo
echo "## Master Certificates"
echo

echo_code_block
grep 'alt names' enterprise/certs.txt | awk '{$3=$4=""; print $0}'
echo_code_block

echo
echo "## File Backup Enabled"
echo

pushd enterprise/find && gunzip --force _opt_puppetlabs.txt.gz && popd

echo_code_block
grep '/opt/puppetlabs/puppet/cache/clientbucket' enterprise/find/_opt_puppetlabs.txt | wc -l
echo_code_block

echo
echo "## Orphaned PostgreSQL Versions"
echo

pushd enterprise/find && gunzip --force _opt_puppetlabs.txt.gz && popd

echo_code_block
egrep '/opt/puppetlabs/server/data/postgresql/\d+.\d+$' enterprise/find/_opt_puppetlabs.txt | awk -F ' ' '{print $NF}'
echo_code_block

echo
echo "## Puppet Enterprise Service Logs"
echo

echo
echo "### Warnings"
echo

echo_code_block
grep 'WARN' logs/*/*.log | cut -d ' ' -f 6- | sort | uniq
echo_code_block

echo
echo "### Errors"
echo

echo_code_block
grep 'ERROR' logs/puppetserver/puppetserver.log | cut -d ' ' -f 6- | sort | uniq`
echo_code_block

echo
echo "## Puppet Enterprise PostgreSQL Temporary Files"
echo

echo_code_block
grep -r 'temporary file' logs/postgresql | wc -l
echo_code_block

echo
echo "## System Logs"
echo

pushd logs && gunzip --force messages.gz && popd

echo_code_block
grep 'puppet-agent' logs/messages | cut -d ' ' -f 7- | grep err | sort | uniq
echo_code_block

echo
echo "Manual Review"
echo

# enterprise console_status.json for errors and jvm-metrics
# enterprise module_changes.txt for changes
# enterprise orchestration_status.json for errors and jvm-metrics
# enterprise puppetdb_status.json for errors and jvm-metrics
# enterprise puppetserver_status.json for errors and jvm-metrics
# enterprise state for master puppet agent run issues
# enterprise thundering_herd_query.txt for herding

# networking ip_tables.txt
# networking ntpq_output.txt
# networking puppet_ping.txt

# resources compare db_sizes_from_du.txt with db_sizes_from_psql.txt
# resources compare filesync_repo_sizes_from_du.txt with r10k_cache_sizes_from_du.txt
# resources db_relation_sizes.txt for large tables
# resources df_output.txt

# system etc / (service) configuration file for tunable settings
# system env.txt for third-party software
# system facter_output.debug.log for warnings and errors
# system hosts for unusual entries
# system ps_aux.txt for third-party software

echo
echo "## Metrics"
echo

echo
echo "### average-free-jrubies"
echo

echo_code_block
grep average-free-jrubies metrics/puppetserver/*/*.json
echo_code_block

echo
echo "### queue_depth"
echo

echo_code_block
grep queue_depth metrics/puppetdb/*/*.json
echo_code_block

# echo
# echo "Puppet Infrastructure Tune"
# echo
