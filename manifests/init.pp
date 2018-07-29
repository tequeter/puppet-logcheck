# @summary Main API
#
# Installs and configure logcheck, a cronjob that sends you the (hopefully)
# interesting bits of your logfiles.
#
# @param ensure
#   Allows to uninstall logcheck.
# @param mailto
#   Who receives the mails (`SENDMAILTO`).
# @param report_level
#   Logcheck suppresses more or less messages depending on the intended usage
#   of this node (`REPORTLEVEL`).
# @param summarize
#   Send logs as-is, as a summary (one line of each type, in chronological
#   order), or as a strict unique list. `as-is` is the default, but `summary`
#   is the most readable (`SORTUNIQ`, `SYSLOGSUMMARY`).
# @param display_intro
#   Include a boilerplate introduction with each mail (`INTRO`).
# @param display_fqdn
#   Display the fully qualified host name instead of just the host part
#   (`FQDN`).
# @param enable_cracking_ignore
#   Enable ignore patterns in the *cracking* layer.
# @param send_as_attachment
#   Sends the log excerpt as an attachement rather than in the mail body
#   (MAILASATTACH).
# @param extra_config
#   Inserts further `NAME=value` pairs in the configuration file.
# @param config_file
#   The configuration file to manage. Most users shouldn't have to touch this.
# @param rulesets
#   Hash data used to define rulesets from Hiera.
class logcheck (
  Pattern['absent', 'present'] $ensure = 'present',

  String $mailto = 'logcheck',
  Pattern['workstation', 'server', 'paranoid'] $report_level = 'server',
  Pattern['as-is', 'summary', 'unique'] $summarize = 'as-is',
  Boolean $display_intro = true,
  Boolean $display_fqdn = true,
  Boolean $enable_cracking_ignore = false,
  Boolean $send_as_attachment = false,

  Hash $extra_config = {},
  Stdlib::Absolutepath $config_file = '/etc/logcheck/logcheck.conf',

  Hash $rulesets = {},
) {

  class { 'logcheck::install':
    ensure    => $ensure,
    summarize => $summarize,
  }

  if $ensure == 'absent' {

    contain('logcheck::install')

  } else {

    class { 'logcheck::config':
      mailto                 => $mailto,
      report_level           => $report_level,
      summarize              => $summarize,
      display_intro          => $display_intro,
      display_fqdn           => $display_fqdn,
      enable_cracking_ignore => $enable_cracking_ignore,
      send_as_attachment     => $send_as_attachment,
      extra_config           => $extra_config,
      config_file            => $config_file,
    }

    create_resources('logcheck::ruleset', $rulesets)

    contain('logcheck::install')
    -> contain('logcheck::config')
  }

}
