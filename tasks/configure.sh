#!/bin/bash
declare PT__installdir
source "$PT__installdir/healthcheck_lite/files/common.sh"

(( $EUID == 0 )) || fail "This utility must be run as root"

[[ $PATH =~ "/opt/puppetlabs/bin" ]] || export PATH="/opt/puppetlabs/bin:${PATH}"

tmp_dir=/var/tmp/puppet_modules
metrics_version='5.1.2'
pe_tune_version='2.3.0'

module_path="$(puppet config print modulepath)" || module_path=
# This really only checks the return code of mapfile, which is ok
# The proper way to do this would be with `jq` and puppet module list --render-as json
mapfile -t module_list < <(puppet module list --modulepath="${tmp_dir}:${module_path}" 2>/dev/null) || {
  fail "Error getting module list"
}

[[ -d $tmp_dir ]] || {
  mkdir "$tmp_dir" || fail "Error creating temp directory"
}

# The install_* task parameters default to true.
# Install to $tmp_dir if install_pe_metrics is not false and neither of the collection modules are not installed
if [[ $install_pe_metrics != "false" ]]; then
  if [[ ! ${module_list[@]} =~ 'pe_metric_curl_cron_jobs'|'puppet_metrics_collector' ]]; then
    puppet module install puppetlabs-puppet_metrics_collector \
      --version "$metrics_version" --modulepath="$tmp_dir" >/dev/null || {
      fail "Error installing the 'puppet_metrics_collector' module, please install manually"
    }
  fi

  # Update module_list in case we installed metrics collection
  mapfile -t module_list < <(puppet module list --modulepath="${tmp_dir}:${module_path}" 2>/dev/null) || {
    fail "Error getting module list"
  }

  # If only the puppet_metrics_collector module is installed, configure it if necessary
  if [[ ! ${module_list[@]} =~ 'pe_metric_curl_cron_jobs' && ${module_list[@]} =~ 'puppet_metrics_collector' ]]; then
    crontab -l | grep -q 'puppetserver_metrics' || {
      puppet apply -e "class { 'puppet_metrics_collector': }" --modulepath="${tmp_dir}:${module_path}" >/dev/null || {
        fail "Error configuring the 'puppet_metrics_collector' module, please install manually"
      }
    }
  fi
fi

if [[ "$install_pe_tune" != "false" ]]; then
  [[ -d ${tmp_dir}/pe_tune ]] || mkdir "$tmp_dir/pe_tune"
  _tmp_tune="$(mktemp)"
  _tmp_tune_dir="$(mktemp -d)"

  curl -sL -o "$_tmp_tune" "https://github.com/tkishel/pe_tune/archive/$pe_tune_version.tar.gz" || {
    fail "Error downloading tarball"
  }

  tar xf "$_tmp_tune" -C "$_tmp_tune_dir" || fail "Error extracting tarball"

  find "$tmp_dir/pe_tune" -mindepth 1 -delete
  # Use wildcards so we don't have to care about the version number
  mv -f "$_tmp_tune_dir/"*/* "$tmp_dir/pe_tune" || fail "Error installing the 'pe_tune' module, please install manually"
fi

success '{ "status": "HealthCheck Lite configured successfully" }'
