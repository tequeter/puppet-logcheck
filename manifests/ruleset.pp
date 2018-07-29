# @summary Configure which log entries should be reported.
#
# Configure which log entries should be reported.
#
# Logcheck sends three types of reports ("layers"), in separate mails:
#
# 1. Cracking attempts ("Security Alerts").
# 2. Policy violations ("Security Events").
# 3. System events.
#
# The first two only include explicitely listed patterns, with further
# filtering through the ignore patterns (i.e. a log line has both to match a
# *report* pattern and not match any *ignore* pattern to be included in these
# reports).
#
# System events include everything, but the lines that match ignore patterns.
# System events are further structured in three levels, with decreasing
# verbosity (i.e. increasing amounts of ignore patterns):
#
# 1. Paranoid.
# 2. Server (the default).
# 3. Workstation.
#
# A global configuration setting determines which level should be used for this
# node. Each level automatically includes everything defined for the previous
# ones (i.e. `server` is `paranoid` plus `server`-specific rules).
#
# A ruleset is defined as a set of patterns for each of the seven possible
# combinations of layers and levels, identified by the name of the system
# component being reported on.
#
# @param title
#   The system component this ruleset relates to. Be careful not to conflict
#   with files in the `logcheck-database` package, unless you actually intend
#   to replace them. I.e. most of the time you should use `smartd_custom` (or
#   some other suffix/prefix), not `smartd`.
# @param ensure
# @param system_workstation_ignore
# @param system_server_ignore
# @param system_paranoid_ignore
# @param violations_ignore
# @param violations_report
# @param cracking_ignore
# @param cracking_report
# @param basedir
#   You should not have to alter this.
define logcheck::ruleset(
  Pattern['absent', 'present'] $ensure = 'present',
  Array[String] $system_workstation_ignore = [],
  Array[String] $system_server_ignore      = [],
  Array[String] $system_paranoid_ignore    = [],
  Array[String] $violations_ignore         = [],
  Array[String] $violations_report         = [],
  Array[String] $cracking_ignore           = [],
  Array[String] $cracking_report           = [],
  Stdlib::Absolutepath $basedir = '/etc/logcheck',
) {

  $_ruleset = {
    'ignore.d.workstation' => $system_workstation_ignore,
    'ignore.d.server'      => $system_server_ignore,
    'ignore.d.paranoid'    => $system_paranoid_ignore,
    'violations.ignore.d'  => $violations_ignore,
    'violations.d'         => $violations_report,
    'cracking.ignore.d'    => $cracking_ignore,
    'cracking.d'           => $cracking_report,
  }

  $_ruleset.each | $_dir, $_rules | {
    file { "${basedir}/${_dir}/${title}":
      ensure  => $ensure,
      content => epp('logcheck/ruleset.epp', { rules => $_rules }),
    }
  }

  Class['logcheck::install'] -> Logcheck::Ruleset[$title]
}
