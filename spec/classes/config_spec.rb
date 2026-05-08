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
      log_sources: 'package',
      syslog_logfiles: ['/var/log/syslog', '/var/log/auth.log'],
      journal_logfiles: ['journal'],
    }
  end

  it { is_expected.to compile }
  it { is_expected.to contain_augeas('logcheck') }
  # rspec-puppet-augeas, where art thou?

  context 'with package log sources' do
    let(:params) do
      super().merge(log_sources: 'package')
    end

    it { is_expected.not_to contain_file('/etc/logcheck/logcheck.logfiles.d/syslog.logfiles') }
    it { is_expected.not_to contain_file('/etc/logcheck/logcheck.logfiles.d/journal.logfiles') }
  end

  context 'with file log sources' do
    let(:params) do
      super().merge(log_sources: 'files')
    end

    it { is_expected.to contain_file('/etc/logcheck/logcheck.logfiles.d/syslog.logfiles').with_content(%r{^/var/log/syslog$}).with_content(%r{^/var/log/auth\.log$}) }
    it { is_expected.to contain_file('/etc/logcheck/logcheck.logfiles.d/journal.logfiles').with_content(%r{^# This log source is disabled by Puppet\.$}) }
  end

  context 'with journal log sources' do
    let(:params) do
      super().merge(log_sources: 'journal')
    end

    it { is_expected.to contain_file('/etc/logcheck/logcheck.logfiles.d/syslog.logfiles').with_content(%r{^# This log source is disabled by Puppet\.$}) }
    it { is_expected.to contain_file('/etc/logcheck/logcheck.logfiles.d/journal.logfiles').with_content(%r{^journal$}) }
  end

  context 'with both log sources' do
    let(:params) do
      super().merge(log_sources: 'both')
    end

    it { is_expected.to contain_file('/etc/logcheck/logcheck.logfiles.d/syslog.logfiles').with_content(%r{^/var/log/syslog$}).with_content(%r{^/var/log/auth\.log$}) }
    it { is_expected.to contain_file('/etc/logcheck/logcheck.logfiles.d/journal.logfiles').with_content(%r{^journal$}) }
  end
end
