# Transforms a logcheck.conf key-value pair into an Augeas instruction.
#
# @param name
#   Variable name, as found in logcheck.conf.
#
# @param value
#   Booleans will be converted to 0/1, Strings will be quoted, Undef will be
#   removed from configuration. Strings may not contain \, ', or ".
#
# @return [String] A *change* instruction string for Augeas.
#
# @api private
function logcheck::augeas_change(
  Pattern[/\A[A-Z_]+\Z/] $name,
  Variant[Pattern[/\A[^\\'"]+\Z/], Integer, Boolean, Undef] $value
) >> String {
  if $value == undef {
    $_change = "rm ${name}"
  } else {
    if $value =~ Boolean {
      if $value {
        $_strval = '1'
      } else {
        $_strval = '0'
      }
    } else {
      $_strval = "\"${value}\"" # Feel free to add quoting for augeas+shell here
    }
    $_change = "set ${name} '${_strval}'"
  }

  $_change
}
