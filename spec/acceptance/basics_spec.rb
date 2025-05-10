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
              system_server_ignore => [ "acceptance_basics_pattern1" ],
            }
          }
        }
      PP
    end

    it 'applies idempotently' do
      idempotent_apply(pp)
    end

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

    context 'when executed' do
      # Produce 3 log messages, two of them dupes to test the summary feature.
      before(:all) do
        %w( pattern1 pattern2 pattern2 ).each do |message|
          shell_result = run_shell("logger acceptance_basics_#{message}")
          expect(shell_result.exit_code).to equal(0)
        end
      end

      describe command('sudo -u logcheck /usr/sbin/logcheck -o') do
        its(:exit_status) { is_expected.to eq 0 }
        its(:stdout) { is_expected.not_to match(%r{pattern1}) }
        its(:stdout) { is_expected.to     match(%r{pattern2}) }
        its(:stdout) { is_expected.not_to match(%r{(pattern2.*){2}}m) } # Shouldn't find a dup
      end
    end
  end
end
