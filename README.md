
# logcheck

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with logcheck](#setup)
    * [What logcheck affects](#what-logcheck-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with logcheck](#beginning-with-logcheck)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Description

Manages logcheck and its pattern rules.


## Setup

### What logcheck affects

Besides the obvious:

* Package `syslog-summary` will be installed if needed. Note: it is never
  removed afterwards, as other parts of the system might depend on it.

### Beginning with logcheck


```puppet
# Install logcheck with its default configuration
include logcheck
```

## Usage

### Typical usage with a single Hiera source

```puppet
include logcheck
```

```yaml
---
logcheck::log_sources: files
logcheck::summarize: summary
logcheck::rulesets:
  postfix_custom:
    system_server_ignore:
      - '^\w{3} [ :0-9]{11} [._[:alnum:]-]+ postfix/cleanup\[[0-9]+\]: [A-Z0-9]+: milter-reject: .* Blocked by SpamAssassin'
      - ... more patterns missing in the default rules ...
  myapp:
    system_server_ignore:
      - "some patterns of log messages that constitute normal server operation"
    violations_report:
      - "important stuff that should be reported in a separate mail"
    violations_ignore:
      - "unless it matches these other patterns"
```

All arguments given through Hiera obviously work from a `class { 'logcheck':
... }` declaration as well.

There are other useful global configuration parameters, see `logcheck` in the
reference documentation. For the explanation of rulesets, see
`logcheck::ruleset`.

### Log sources

By default this module leaves the package-provided log source selection alone:

```puppet
class { 'logcheck':
  log_sources => 'package',
}
```

Use `files`, `journal`, or `both` to manage
`/etc/logcheck/logcheck.logfiles.d/syslog.logfiles` and
`/etc/logcheck/logcheck.logfiles.d/journal.logfiles` explicitly.

```puppet
class { 'logcheck':
  log_sources => 'files',
}
```

On Debian 13, the package defaults may read both classic log files and the
systemd journal. If both contain the same messages, logcheck can report
duplicates. Journal reads may also trigger SELinux violations where the local
policy does not allow the logcheck user to read the journal. On hosts where
rsyslog log files are available, `log_sources => 'files'` avoids both issues.

### Integration with logcheck from profiles or other modules

```puppet
logcheck::ruleset { 'myapp':
  system_server_ignore => file('myapp/system_server_ignore.txt'),
  violations_report    => [ ... ],
  violations_ignore    => [ ... ],
}
```

This will use a pattern file from `modules/myapp/files/...` and some patterns
provided as arrays.

## Reference

Please refer to [REFERENCE.md](REFERENCE.md).

## Limitations

* Some `logcheck.conf` configuration options are missing from the user-friendly
  interface (but may be set through the `extra_options` arg).
