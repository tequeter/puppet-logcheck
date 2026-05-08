# @summary Configure global logcheck behavior
#
# Configure logcheck.conf from some user-friendly parameters and extra
# configuration values. The args are documented in [`logcheck`](#logcheck).
#
# This is part of the public API, but most users should prefer the `logcheck`
# class.
#
# @param mailto
# @param report_level
# @param summarize
# @param display_intro
# @param display_fqdn
# @param enable_cracking_ignore
# @param send_as_attachment
# @param log_sources
# @param syslog_logfiles
# @param journal_logfiles
# @param extra_config
# @param config_file
class logcheck::config (
  String $mailto,
  Pattern['workstation', 'server', 'paranoid'] $report_level,
  Pattern['as-is', 'summary', 'unique'] $summarize,
  Boolean $display_intro,
  Boolean $display_fqdn,
  Boolean $enable_cracking_ignore,
  Boolean $send_as_attachment,
  Enum['package', 'files', 'journal', 'both'] $log_sources,
  Array[Stdlib::Absolutepath] $syslog_logfiles,
  Array[String[1]] $journal_logfiles,

  Hash $extra_config = {},
  Stdlib::Absolutepath $config_file = '/etc/logcheck/logcheck.conf',

  String $disabled_content = "# This log source is disabled by Puppet.\n",
  String $syslog_sources =
    if $log_sources in ['files', 'both'] {
      "${syslog_logfiles.join("\n")}\n"
    } else {
      $disabled_content
    },
  String $journal_sources =
    if $log_sources in ['journal', 'both'] {
      "${journal_logfiles.join("\n")}\n"
    } else {
      $disabled_content
    },
) {

  case $summarize {
    'unique': {
      $_sortuniq = true
      $_syslogsummary = false
    }
    'summary': {
      $_sortuniq = false
      $_syslogsummary = true
    }
    default: {
      $_sortuniq = false
      $_syslogsummary = false
    }
  }

  $_entries = {
    'INTRO'                   => $display_intro,
    'REPORTLEVEL'             => $report_level,
    'SENDMAILTO'              => $mailto,
    'MAILASATTACH'            => $send_as_attachment,
    'FQDN'                    => $display_fqdn,
    'SUPPORT_CRACKING_IGNORE' => $enable_cracking_ignore,
    'SORTUNIQ'                => $_sortuniq,
    'SYSLOGSUMMARY'           => $_syslogsummary,
  } + $extra_config

  $_changes = $_entries.map | $_key, $_value | { logcheck::augeas_change($_key, $_value) }

  augeas { 'logcheck':
    lens    => 'Shellvars.lns',
    incl    => $config_file,
    context => "/files/${config_file}",
    changes => $_changes,
  }

  if $log_sources != 'package' {
    file { '/etc/logcheck/logcheck.logfiles.d/syslog.logfiles':
      ensure  => file,
      content => $syslog_sources,
    }

    file { '/etc/logcheck/logcheck.logfiles.d/journal.logfiles':
      ensure  => file,
      content => $journal_sources,
    }
  }
}
