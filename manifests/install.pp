# @summary Manage packages
#
# Manage the `logcheck` and `syslog-summary` packages.
#
# This is part of the public API, but most users should prefer the `logcheck`
# class.
#
# The `syslog-summary` package may be installed to support `summary` summarize,
# but is never uninstalled as it may break other parts of the system who might
# rely on it.
#
# @param ensure
#   Allows to uninstall logcheck.
# @param summarize
#   Triggers management of `syslog-summary` when `summarize` requires it.
class logcheck::install (
  Pattern['absent', 'present'] $ensure,
  String $summarize,
) {
  package { 'logcheck':
    ensure => $ensure,
  }

  if $summarize == 'summary' and $ensure == 'present' {
    package { 'syslog-summary':
      ensure => 'present',
    }
  }
}
