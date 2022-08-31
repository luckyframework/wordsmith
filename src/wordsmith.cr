require "./wordsmith/**"

# Wordsmith is a library for pluralizing, ordinalizing, singularizing and doing other fun and useful things with words.
module Wordsmith
  # The current Wordsmith version is defined in `shard.yml`
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
end
