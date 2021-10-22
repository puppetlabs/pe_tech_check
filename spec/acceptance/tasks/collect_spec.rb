require 'spec_helper_acceptance'

describe 'collect module task defaults' do
  it 'returns success' do
    run_shell(' mkdir -p /var/tmp/pe_tech_check/; chmod 777 /var/tmp/pe_tech_check/ ;chmod 1777 /tmp')
    result = run_bolt_task('pe_tech_check::collect')
    expect(result.stdout).to contain(%r{Tech Check complete. Please upload the resultant file to Puppet})
  end
end
