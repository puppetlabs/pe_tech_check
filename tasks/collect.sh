#!/bin/bash

temp_module_directory=/var/tmp/puppet_modules
output_directory=/var/tmp/health_check_lite
output_file=$output_directory/health_check_lite.txt
support_script_output_file=$output_directory/support_script_output.log

echo "Collecting HealthCheck Lite"

mkdir -p $output_directory
rm -f $output_directory/*.gz

echo "Puppet Enterprise HealthCheck Lite: $(date)" > $output_file
echo "Run as $(whoami)" >> $output_file
echo >> $output_file

grep -i -v UUID /etc/puppetlabs/license.key >> $output_file 2>/dev/null
echo >> $output_file

/opt/puppetlabs/bin/puppet enterprise support --classifier --dir $output_directory --log-age 3 --ticket HCL > $support_script_output_file 2>&1

if [ -d $temp_module_directory/pe_tune ]; then
  echo 'puppet pe tune' >> $output_file
  puppet pe tune --modulepath $temp_module_directory >> $output_file 2>/dev/null
  echo >> $output_file

  echo 'puppet pe tune --current' >> $output_file
  puppet pe tune --modulepath $temp_module_directory --current >> $output_file 2>/dev/null
  echo >> $output_file
else
  echo '/opt/puppetlabs/bin/puppet-infrastructure tune' >> $output_file
  /opt/puppetlabs/bin/puppet-infrastructure tune >> $output_file 2>/dev/null
  echo >> $output_file

  echo '/opt/puppetlabs/bin/puppet-infrastructure tune --current' >> $output_file
  /opt/puppetlabs/bin/puppet-infrastructure --current >> $output_file 2>/dev/null
  echo >> $output_file
fi

echo "Done. Please upload the following files to Puppet:"
echo
ls -1 $output_directory/*.gz
ls -1 $output_file
