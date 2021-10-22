require 'spec_helper_acceptance'

describe 'configure module metrics install is false' do
  it 'returns success' do
    result = run_bolt_task('pe_tech_check::configure', 'install_pe_metrics' => 'false')
    expect(result.stdout).to contain(%r{success})
  end
end
