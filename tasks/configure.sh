#!/bin/bash

# The install_* task parameters default to true.

if [ "X$PT_install_pe_metrics" = "Xfalse" ]; then
  install_pe_metrics="FALSE"
else
  install_pe_metrics="TRUE"
fi

if [ "X$PT_install_pe_tune" = "Xfalse" ]; then
  install_pe_tune="FALSE"
else
  install_pe_tune="TRUE"
fi

temp_module_directory=/var/tmp/puppet_modules
puppet_metrics_collector_version='5.1.2'
pe_tune_version='2.3.0'
old_metrics_module='pe_metric_curl_cron_jobs'
new_metrics_module='puppet_metrics_collector'

echo "Configuring PE Tech Check"

puppet_module_path=$(puppet config print modulepath 2>/dev/null)
if [ $? -ne 0 ]; then
  puppet_module_path=''
else
  puppet_module_path="$puppet_module_path:"
fi

# Temporarily install puppet_metrics_collector, unless pe_metric_curl_cron_jobs or puppet_metrics_collector is installed.

if [ "$install_pe_metrics" = "TRUE" ]; then
  mkdir -p $temp_module_directory

  module_list=$(puppet module list --modulepath=$puppet_module_path$temp_module_directory 2>/dev/null)
  if [[ ! $module_list =~ $old_metrics_module ]] && [[ ! $module_list =~ $new_metrics_module ]]; then
    echo "Installing the 'puppet_metrics_collector' module"
    puppet module install puppetlabs-puppet_metrics_collector --version $puppet_metrics_collector_version --modulepath=$temp_module_directory > /dev/null 2>&1
    module_list=$(puppet module list --modulepath=$temp_module_directory 2>/dev/null)
    if [[ $module_list =~ $new_metrics_module ]]; then
      echo "  Installed the 'puppet_metrics_collector' module"
    else
      echo "  Error installing the 'puppet_metrics_collector' module, please install manually"
    fi
  fi

  # Configure puppet_metrics_collector, unless pe_metric_curl_cron_jobs or puppet_metrics_collector is configured.

  if [[ ! $module_list =~ $old_metrics_module ]] && [[ $module_list =~ $new_metrics_module ]]; then
    crontab -l | grep 'puppetserver_metrics' > /dev/null 2>&1
    if [ $? -ne 0 ]; then
      echo "Configuring the 'puppet_metrics_collector' module"
      puppet apply -e "class { 'puppet_metrics_collector': }" --modulepath=$puppet_module_path$temp_module_directory > /dev/null 2>&1
      crontab -l | grep 'puppetserver_metrics' > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        echo "  Configured the 'puppet_metrics_collector' module"
      else
        echo "  Error configuring the 'puppet_metrics_collector' module, please configure manually"
      fi
    fi
  fi
fi

# Temporarily install the latest version of `puppet infra tune` from its upstream repository.

if [ "$install_pe_tune" = "TRUE" ]; then
  mkdir -p $temp_module_directory

  if [ ! -d $temp_module_directory/pe_tune ]; then
    echo "Installing the 'pe_tune' module"
    curl -s -L https://github.com/tkishel/pe_tune/archive/$pe_tune_version.tar.gz | tar -xzf - > /dev/null 2>&1
    if [ -d pe_tune-$pe_tune_version ]; then
      mv -f pe_tune-$pe_tune_version $temp_module_directory/pe_tune > /dev/null 2>&1
      if [ -d $temp_module_directory/pe_tune ]; then
        echo "  Installed the 'pe_tune' module"
      else
        echo "  Error installing the 'pe_tune' module, please install manually"
      fi
    fi
  fi
fi

echo "Done"
echo
