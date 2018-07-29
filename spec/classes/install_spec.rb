require 'spec_helper'

describe 'logcheck::install' do
  context 'with present and non-summary args' do
    let(:params) do
      {
        ensure: 'present',
        summarize: 'as-is',
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_package('logcheck') }
    it { is_expected.not_to contain_package('syslog-summary') }
  end

  context 'with present and summary args' do
    let(:params) do
      {
        ensure: 'present',
        summarize: 'summary',
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_package('logcheck') }
    it { is_expected.to contain_package('syslog-summary') }
  end

  context 'with absent arg' do
    let(:params) do
      {
        ensure: 'absent',
        summarize: 'summary',
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_package('logcheck').with_ensure('absent') }
    it { is_expected.not_to contain_package('syslog-summary') }
  end
end
