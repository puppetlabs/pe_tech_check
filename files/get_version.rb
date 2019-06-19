#!/opt/puppetlabs/puppet/bin/ruby
require 'puppet'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.2') >= 0
  exit 0
else
  exit 1
end
