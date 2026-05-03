require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-strings/tasks' if Bundler.rubygems.find_name('puppet-strings').any?
if Bundler.rubygems.find_name('puppet_litmus').any?
  require 'puppet_litmus/rake_tasks'
  require_relative 'support/bolt_podman_json_patch'
end
