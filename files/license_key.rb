require 'yaml'

class LicenseKey
  attr_reader :uuid
  attr_reader :to
  attr_reader :nodes
  attr_reader :expiration_date

  def initialize()
    license_key = YAML.load_file('/etc/puppetlabs/license.key')

    @uuid            = license_key['uuid']
    @to              = license_key['to']
    @nodes           = license_key['nodes']
    @expiration_date = license_key['end'].to_s
    license_key
  rescue Exception => e
    license_key = {
      'error' => 'Missing or malformed license key file.',
      'uuid'  => '',
      'to'    => '',
      'nodes' => '',
      'end'   => '',
    }
    license_key
  end

end