require 'beaker-rspec/spec_helper'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

# Monkey-patch until Buster is supported
hosts.each do |host|
  platform = host['platform']
  next if platform !~ %r{^debian-10-} || platform.codename
  def platform.codename=(codename) # rubocop:disable Style/TrivialAccessors
    @codename = codename
  end
  platform.codename = 'stretch'
end

run_puppet_install_helper
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Allow running a subset of the tests, but run everything otherwise
  c.filter_run focus: true
  c.run_all_when_everything_filtered = true

  c.formatter = :documentation
end

shared_examples 'a idempotent resource' do
  it 'applies with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'applies a second time without changes' do
    apply_manifest(pp, catch_changes: true)
  end
end
