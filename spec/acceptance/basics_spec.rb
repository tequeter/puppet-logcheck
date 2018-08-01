require 'spec_helper_acceptance'

describe 'logcheck class' do
  context 'default parameters' do
    let(:pp) do
      <<-'PP'
        class { 'logcheck':
          summarize => 'summary',
          mailto    => 'beaker',
          rulesets  => {
            beaker_basics_spec => {
              system_server_ignore => [ "beaker_basics_pattern1" ],
            }
          }
        }
      PP
    end

    it_behaves_like 'a idempotent resource'

    describe package('logcheck') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/logcheck/logcheck.conf') do
      its(:content) { is_expected.to match(%r{^SENDMAILTO="beaker"$}) }
    end

    describe file('/etc/logcheck/ignore.d.server/beaker_basics_spec') do
      it { is_expected.to exist }
      its(:content) { is_expected.to match(%r{pattern1}) }
    end

    shell('logger beaker_basics_pattern1')
    shell('logger beaker_basics_pattern2')
    shell('logger beaker_basics_pattern2') # Dup to check summary

    describe command('sudo -u logcheck /usr/sbin/logcheck -o') do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.not_to match(%r{pattern1}) }
      its(:stdout) { is_expected.to     match(%r{pattern2}) }
      its(:stdout) { is_expected.not_to match(%r{(pattern2.*){2}}m) } # Shouldn't find a dup
    end
  end
end
