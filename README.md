
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

### Integration with logcheck from profiles or other modules

```puppet
logcheck::ruleset { 'myapp':
  system_server_ignore => [ ... ],
  violations_report    => [ ... ],
  violations_ignore    => [ ... ],
}
```

## Reference

Please refer to [REFERENCE.md](REFERENCE.md).

## Limitations

* Some `logcheck.conf` configuration options are missing from the user-friendly
  interface (but may be set through the `extra_options` arg).
