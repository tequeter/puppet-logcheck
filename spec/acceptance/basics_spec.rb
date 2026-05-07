require 'spec_helper_acceptance'

describe 'logcheck class' do
  context 'with default parameters' do
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
      expect { idempotent_apply(pp) }.not_to raise_error
    end

    it 'installs the logcheck package' do
      shell_result = run_shell('dpkg-query -W logcheck')
      expect(shell_result.exit_code).to eq(0)
    end

    it 'configures the recipient' do
      shell_result = run_shell(%q(grep -Fx 'SENDMAILTO="beaker"' /etc/logcheck/logcheck.conf))
      expect(shell_result.exit_code).to eq(0)
    end

    it 'creates the server ignore ruleset' do
      shell_result = run_shell('grep pattern1 /etc/logcheck/ignore.d.server/beaker_basics_spec')
      expect(shell_result.exit_code).to eq(0)
    end

    context 'when executed' do
      before(:all) do
        # Produce 3 log messages, two of them dupes to test the summary feature.
        ['pattern1', 'pattern2', 'pattern2'].each do |message|
          shell_result = run_shell("logger acceptance_basics_#{message}")
          raise 'logger failed' unless shell_result.exit_code.zero?
        end
      end

      it 'reports only unmatched messages once' do
        shell_result = run_shell('runuser -u logcheck -- /usr/sbin/logcheck -o')

        expect(shell_result.exit_code).to eq(0)
        expect(shell_result.stdout).not_to match(%r{pattern1})
        expect(shell_result.stdout).to     match(%r{pattern2})
        expect(shell_result.stdout).not_to match(%r{(pattern2.*){2}}m) # Shouldn't find a dup
      end
    end
  end
end
