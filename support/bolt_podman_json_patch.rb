# frozen_string_literal: true

require 'bolt/transport/podman/connection'

# Compatibility patch for Bolt 4.0.0 with Podman 5.x.
#
# Bolt's Podman transport runs `podman ps --format '{{json .}}'` and parses the
# result with assumptions that matched older Podman output. On Debian 13 with
# Podman 5.4.2, that command emits one plain JSON object per container. Bolt can
# then fail before acceptance tests run, usually with one of:
#
# - Failed to connect to sut: no implicit conversion of String into Integer
# - Could not find a container with name or ID matching ...
#
# This is tracked upstream as https://github.com/puppetlabs/bolt/issues/3366.
# There is no newer `bolt` gem than 4.0.0 at the time this was added, and
# puppet_litmus loads Bolt as a Ruby library, so installing packaged Bolt 5.x is
# not a drop-in fix for these Rake tasks.
#
# Use Podman's native JSON output mode instead. `--format json` returns arrays
# for both `podman ps` and `podman inspect`, which is the shape Bolt's transport
# code expects when finding and inspecting the target container.
module Bolt
  module Transport
    class Podman
      class Connection
        def execute_local_json_command(subcommand, arguments = [])
          cmd = [subcommand, '--format', 'json'].concat(arguments)
          out, err, stat = run_cmd(cmd, env_hash)

          raise "podman #{cmd.join(' ')} failed: #{err}" unless stat.exitstatus.zero?

          extract_json(out)
        end

        private

        def extract_json(stdout)
          parsed = JSON.parse(stdout)
          parsed.is_a?(Array) ? parsed : [parsed]
        end
      end
    end
  end
end
