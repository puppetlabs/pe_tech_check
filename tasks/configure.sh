#!/bin/bash
# shellcheck disable=SC2004
# shellcheck disable=SC2154

# NOTE: this script can be skipped entirely if the metrics collector is already installed
# Otherwise, run `bolt task run pe_tech_check::configure --nodes localhost` from inside a Boltdir
# with puppet_metrics_collector installed to ./modules

(( $EUID == 0 )) || fail "This utility must be run as root"

declare PT__installdir
source "$PT__installdir/pe_tech_check/files/common.sh"
[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

# The install_* task parameters default to true.
# If neither metrics collection module is installed and $install_pe_metrics != "false":
# apply the 'puppet_metrics_collector' class from ./modules acquired via `bolt puppetfile install`
if ! [[ -e /opt/puppetlabs/puppet-metrics-collector || -e /opt/puppetlabs/pe_metric_curl_cron_jobs ]] && [[ $install_pe_metrics != "false" ]]; then
   puppet apply -e "class { 'puppet_metrics_collector': }" --modulepath="./modules" >/dev/null || {
   fail "Error configuring the 'puppet_metrics_collector' module, please install manually"
   }
fi

success '{ "status": "PE Tech Check configured successfully" }'
