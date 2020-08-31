# Wordsmith

Wordsmith is a library for pluralizing, ordinalizing, singularizing and doing
other fun and useful things with words.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  wordsmith:
    github: luckyframework/wordsmith
    version: ~> 0.2
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
Wordsmith::Inflector.dasherize("PostOffice") # "post-office"
Wordsmith::Inflector.ordinalize(4) # "4th"
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
