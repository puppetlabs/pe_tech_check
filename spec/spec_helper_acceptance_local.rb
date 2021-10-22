# frozen_string_literal: true

require 'singleton'
require 'serverspec'
require 'puppetlabs_spec_helper/module_spec_helper'
include PuppetLitmus

RSpec.configure do |c|
  c.mock_with :rspec
  c.before :suite do
    pp = <<-PUPPETCODE
      if $facts['os']['family'] == 'RedHat' {
        ini_setting { "yum skip_if_unavailable":
          ensure  => present,
          path    => '/etc/yum.conf',
          section => 'main',
          setting => 'skip_if_unavailable',
          value   => 'True',
        }
      }
    PUPPETCODE
    PuppetLitmus::PuppetHelpers.apply_manifest(pp)
    # Download the plugins to ensure up-to-date facts
    PuppetLitmus::PuppetHelpers.run_shell('/opt/puppetlabs/bin/puppet plugin download')
  end
end
