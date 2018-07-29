# Accepts an array of patterns or a literal pattern file contents (one pattern
# per line). In the latter case, we check that it is either empty or ends with
# a newline, to match the POSIX standard.
type Logcheck::Patternsource = Variant[
  Array[String],
  Pattern[/\A\Z|\n\Z/],
]
