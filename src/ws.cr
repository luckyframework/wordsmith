require "option_parser"
require "colorize"
require "./wordsmith"

if STDIN.info.type.pipe?
  ARGV << STDIN.gets.not_nil!
else
  ARGV << "--help" if ARGV.empty?
end

OptionParser.parse do |parser|
  parser.banner = <<-USAGE
Usage: ws <option> WORD

Wordsmith is a library for pluralizing, singularizing and doing
other fun and useful things with words.

Command `ws` is the command line version of Wordsmith, not all
features of Wordsmith are implemented, for precompiled binary,
please download from github releases page.

https://github.com/luckyframework/wordsmith/releases

some examples:

$: #{"ws -s people".colorize(:light_yellow)} # => person
$: #{"ws -p person".colorize(:light_yellow)} # => people

You can use it with pipe:

$: #{"echo \"WordSmith\" |ws -u |ws -d".colorize(:light_yellow)} # => word-smith

more examples, please check https://github.com/luckyframework/wordsmith#usage

USAGE

  parser.on(
    "-s WORD",
    "--singularize=WORD",
    "Return the singular version of the word."
  ) do |word|
    puts Wordsmith::Inflector.singularize(word)
  end

  parser.on(
    "-p WORD",
    "--pluralize=WORD",
    "Return the plural version of the word."
  ) do |word|
    puts Wordsmith::Inflector.pluralize(word)
  end

  parser.on(
    "-c WORD",
    "--camelize=WORD",
    "Return the camel-case version of that word."
  ) do |word|
    puts Wordsmith::Inflector.camelize(word)
  end

  parser.on(
    "-C WORD",
    "--camelize-downcase=WORD",
    "Return the camel-case version of that word, but the first letter not capitalized."
  ) do |word|
    puts Wordsmith::Inflector.camelize(word)
  end

  parser.on(
    "-u WORD",
    "--underscore=WORD",
    "Convert a given camel-case word to it's underscored version."
  ) do |word|
    puts Wordsmith::Inflector.underscore(word)
  end

  parser.on(
    "-d WORD",
    "--dasherize=WORD",
    "Convert a given underscore-separated word to the same word, separated by dashes."
  ) do |word|
    puts Wordsmith::Inflector.dasherize(word)
  end

  parser.on("-h", "--help", "Show this help") do
    puts parser
    exit
  end

  parser.on("-v", "--version", "Show Wordsmith version") do
    puts Wordsmith::VERSION
    exit
  end

  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option.\n\n"
    STDERR.puts parser
    exit 1
  end
end
