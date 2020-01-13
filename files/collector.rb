#!/opt/puppetlabs/puppet/bin/ruby
require 'json'

# This is the entry for additional information.  Add the classes
# for the information as external files with required classes.
# Those classes should instantiate objects which can be read
# and output into a json file in an automated fashion.

require './license_key'

# Include classes we want output for

class_list = [
  'LicenseKey',
]

# File to store the data in
data_file = File.open('/etc/puppetlabs/pe_tech_check_additions.json', 'w')
data_store = {}

# For each item in the class list, call it and write it's
# result to a json file.
class_list.each do |name| 
  puts "Collecting #{name} data..."
  report_hash = {}
  report_object = Object.const_get(name).new()
  report_object.instance_variables.each {|var| report_hash[var.to_s.delete("@")] = report_object.instance_variable_get(var) }
  data_store.store(name, report_hash)
end

# Write out the data file and then close it.
puts "Writing /etc/puppetlabs/pe_tech_check_additions.json"
data_file.puts data_store.to_json
data_file.close