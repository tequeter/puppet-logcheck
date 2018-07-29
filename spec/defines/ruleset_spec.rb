require 'spec_helper'

describe 'logcheck::ruleset' do
  let :pre_condition do
    'include logcheck'
  end
  let(:title) { 'testme' }
  let(:params) do
    {
      system_server_ignore: ['pattern1', 'pattern2'],
    }
  end

  it { is_expected.to compile }
  it { is_expected.to contain_file('/etc/logcheck/ignore.d.server/testme').with_content(%r{^pattern1$}m).with_content(%r{^pattern2$}m) }
  it { is_expected.to have_file_resource_count(7) }
end
