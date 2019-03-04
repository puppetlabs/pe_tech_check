#!/bin/bash

# Exit with debugging upon error.

function trap_exit() {
  [ "$1" -ne "0" ] && echo Error: Command [$2] failed with error code [$1] ... exiting.
}
trap 'trap_exit $? "$BASH_COMMAND"' EXIT

# Enable exit upon error.

function enable_trap_exit() {
  set -e
}

function disable_trap_exit() {
  set +e
}

enable_trap_exit

# Variables

module_directory=/var/tmp/puppet_modules
output_directory=/var/tmp/health_check_lite
output_file=$output_directory/health_check_lite.txt
puppet_metrics_collector_version='5.1.2'
pe_tune_version='2.3.0'

echo
echo "# Health Check Lite Data Collection"
echo

#### Step One: Module Installation

echo
echo "## Installing Modules, please wait ..."
echo

mkdir -p $module_directory

##### puppet_metrics_collector module

module_list=$(puppet module list)
old_metrics='pe_metric_curl_cron_jobs'
new_metrics='puppet_metrics_collector'

# Temporarily install and configure puppet_metrics_collector,
# unless pe_metric_curl_cron_jobs or puppet_metrics_collector is installed.

disable_trap_exit

if [[ ! $module_list =~ $old_metrics ]]; then
  if [[ ! $module_list =~ $new_metrics ]]; then
    if [ ! -d $module_directory/$new_metrics ]; then
      puppet module install puppetlabs-puppet_metrics_collector --version $puppet_metrics_collector_version --modulepath $module_directory > /dev/null 2>&1 || true
    fi
    if [ -d $module_directory/$new_metrics ]; then
      puppet apply -e "class { 'puppet_metrics_collector': }" --modulepath $module_directory > /dev/null 2>&1 || true
    fi
  fi
fi

enable_trap_exit

##### pe_tune module

# Temporarily install pe_tune in favor of an older version of puppet infra tune.

disable_trap_exit

if [ ! -d $module_directory/pe_tune ]; then
  curl -s -L https://github.com/tkishel/pe_tune/archive/$pe_tune_version.tar.gz | tar -xzf -
  if [ -d pe_tune-$pe_tune_version ]; then
    mv pe_tune-$pe_tune_version $module_directory/pe_tune
  fi
fi

enable_trap_exit

#### Step Two: Data Collection

echo
echo "## Collecting Data, please wait ..."
echo

if [ -d $output_directory ]; then
  mv $output_directory $output_directory.$$
fi

mkdir -p $output_directory

echo "Puppet Enterprise Health Check Lite: $(date)" > $output_file

echo
echo "### Running 'puppet enterprise support', please wait ..."
echo

puppet enterprise support --classifier --dir $output_directory --log-age 3 --ticket HCL

# Run either puppet pe tune or puppet infra tune.

disable_trap_exit

if [ -d $module_directory/pe_tune ]; then
  echo
  echo "### Running 'puppet pe tune', please wait ..."
  echo
  echo "puppet pe tune" >> $output_file
  puppet pe tune --modulepath $module_directory            >> $output_file 2>&1 || true
  echo "puppet pe tune --estimate" >> $output_file
  puppet pe tune --modulepath $module_directory --estimate >> $output_file 2>&1 || true
  echo "puppet pe tune --current" >> $output_file
  puppet pe tune --modulepath $module_directory --current  >> $output_file 2>&1 || true
  echo "puppet pe tune --compare" >> $output_file
  puppet pe tune --modulepath $module_directory --compare  >> $output_file 2>&1 || true
else
  echo
  echo "###  Running 'puppet infra tune', please wait ..."
  echo
  echo "puppet infra tune" >> $output_file
  puppet infra tune            >> $output_file 2>&1 || true
  echo "puppet infra tune --estimate" >> $output_file
  puppet infra tune --estimate >> $output_file 2>&1 || true
  echo "puppet infra tune --current" >> $output_file
  puppet infra tune --current  >> $output_file 2>&1 || true
fi

enable_trap_exit

echo
echo "# Health Check Lite Data Collection Complete"
echo

echo
echo "## Please upload the following files to Puppet Enterprise Support."
echo

ls -1 $output_file
ls -1 $output_directory/*.gz

echo
