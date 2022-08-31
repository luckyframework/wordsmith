# Wordsmith

[![API Documentation Website](https://img.shields.io/website?down_color=red&down_message=Offline&label=API%20Documentation&up_message=Online&url=https%3A%2F%2Fluckyframework.github.io%2Fwordsmith%2F)](https://luckyframework.github.io/wordsmith)

Wordsmith is a library for pluralizing, ordinalizing, singularizing and doing
other fun and useful things with words.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  wordsmith:
    github: luckyframework/wordsmith
```

## Usage

```crystal
require "wordsmith"

Wordsmith::Inflector.pluralize("word") # "words"
Wordsmith::Inflector.singularize("categories") # "category"
Wordsmith::Inflector.camelize("application_controller") # "ApplicationController"
Wordsmith::Inflector.underscore("CheeseBurger") # "cheese_burger"
Wordsmith::Inflector.humanize("employee_id") # "Employee"
Wordsmith::Inflector.titleize("amazon web services") # "Amazon Web Services"
Wordsmith::Inflector.tableize("User") # "users"
Wordsmith::Inflector.classify("users") # "User"
Wordsmith::Inflector.dasherize("post_office") # "post-office"
Wordsmith::Inflector.ordinalize(4) # "4th"
Wordsmith::Inflector.demodulize("Helpers::Mixins::User") # "User"
Wordsmith::Inflector.deconstantize("User::FREE_TIER_COMMENTS") # "User"
Wordsmith::Inflector.foreign_key("Person") # "person_id"
Wordsmith::Inflector.parameterize("Admin/product") # "admin-product"
```

Wordsmith comes with a `ws` CLI utility which allows you to process words from the command line. You can download it directly from the [releases page](https://github.com/luckyframework/wordsmith/releases).

```sh
 ╰─ $ ./ws 
Usage: ws <option> WORD

Wordsmith is a library for pluralizing, singularizing and doing
other fun and useful things with words.

Command `ws` is the command line version of Wordsmith, not all
features of Wordsmith are implemented, for precompiled binary,
please download from github releases page.

https://github.com/luckyframework/wordsmith/releases

some examples:

$: ws -s people # => person
$: ws -p person # => people

You can use it with pipe:

$: echo "WordSmith" |ws -u |ws -d # => word-smith

more examples, please check https://github.com/luckyframework/wordsmith#usage

    -s WORD, --singularize=WORD      Return the singular version of the word.
    -p WORD, --pluralize=WORD        Return the plural version of the word.
    -c WORD, --camelize=WORD         Return the camel-case version of that word.
    -C WORD, --camelize-downcase=WORD
                                     Return the camel-case version of that word, but the first letter not capitalized.
    -u WORD, --underscore=WORD       Convert a given camel-case word to it's underscored version.
    -d WORD, --dasherize=WORD        Convert a given underscore-separated word to the same word, separated by dashes.
    -h, --help                       Show this help
```

## Custom inflections

If something isn't pluralizing correctly, it's easy to customize.

```crystal
# Place this in a config file like `config/inflectors.cr`
require "wordsmith"

# To pluralize a single string in a specific way
Wordsmith::Inflector.inflections.irregular("human", "humans")

# To stop Wordsmith from pluralizing a word altogether
Wordsmith::Inflector.inflections.uncountable("equipment")
```

## Contributing

1. Fork it ( https://github.com/luckyframework/wordsmith/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Make your changes
4. Run `./bin/test` to run the specs, build shards, and check formatting
5. Commit your changes (git commit -am 'Add some feature')
6. Push to the branch (git push origin my-new-feature)
7. Create a new Pull Request

## Testing

To run the tests:

- Run the tests with `./bin/test`

## Contributors

- [paulcsmith](https://github.com/paulcsmith) Paul Smith - creator, maintainer
- [actsasflinn](https://github.com/actsasflinn) Flinn Mueller - contributor

## Thanks & attributions

- Inflector is based on [Rails](https://github.com/rails/rails). Thank you to the Rails team!
