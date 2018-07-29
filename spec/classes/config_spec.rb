require 'spec_helper'

describe 'logcheck::config' do
  let(:params) do
    {
      mailto: 'test',
      report_level: 'server',
      summarize: 'as-is',
      display_intro: true,
      display_fqdn: true,
      enable_cracking_ignore: true,
      send_as_attachment: false,
    }
  end

  it { is_expected.to compile }
  it { is_expected.to contain_augeas('logcheck') }
  # rspec-puppet-augeas, where art thou?
end
