require 'spec_helper'

describe 'logcheck' do
  context 'with default args' do
    it { is_expected.to compile }
    it { is_expected.to contain_class('logcheck::install') }
    it { is_expected.to contain_class('logcheck::config').that_requires('Class[logcheck::install]') }
    # Would be nice to test one augeas change here, but rspec-puppet-augeas is broken :(
  end

  context 'with rulesets' do
    let(:params) do
      {
        rulesets: { test: {} },
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_logcheck__ruleset('test').that_requires('Class[logcheck::install]') }
  end

  context 'with ensure absent' do
    let(:params) do
      {
        ensure: 'absent',
      }
    end

    it { is_expected.to compile }
    it { is_expected.to contain_class('logcheck::install').with_ensure('absent') }
  end
end
