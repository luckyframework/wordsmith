module Wordsmith
  module Inflector
    extend self

    # Store the current set of stored inflection logic.
    @@inflections = Inflections.new

    # Return the current set of stored inflection logic.
    def inflections
      @@inflections
    end

    # Create and manipulate the set of valid Wordsmith inflections.
    class Inflections
      # Create and manipulate the set of words that Wordsmith should leave as-is.
      class Uncountables
        forward_missing_to @uncoundtables_array

        # Create a new object to store the collection of uncountable words and patterns.
        def initialize
          @regex_array = Array(Regex).new
          @uncoundtables_array = [] of String
        end

        # Remove an entry from the set of uncountable words and patterns.
        def delete(entry)
          @uncoundtables_array.delete entry
          @regex_array.delete(to_regex(entry))
        end

        # Add an entry to the set of uncountable words and patterns.
        def add(words)
          words = words.to_a.flatten.map(&.downcase)
          concat(words)
          @regex_array += words.map { |word| to_regex(word) }
          self
        end

        # :ditto:
        def <<(*word)
          add(word)
        end

        # Check whether or not a provided string is currently considered uncountable.
        def uncountable?(str)
          @regex_array.any?(&.match(str))
        end

        # Convert a provided string to a regular expression.
        private def to_regex(string)
          /\b#{::Regex.escape(string)}\Z/i
        end
      end

      # Return the current set of matched pluralization patterns.
      getter :plurals

      # Return the current set of matched singularization patterns.
      getter :singulars

      # Return the current set of items considered uncountable.
      getter :uncountables

      # Return the current set of items that can be humanized.
      getter :humans

      # Return the current set of acronym strings to recognize.
      getter :acronyms

      # Return the current set of acronym `Regex` patterns to recognize.
      getter :acronym_regex

      # Create a new object to store the collection of inflectable words and patterns.
      def initialize
        @plurals = Hash(Regex, String).new
        @singulars = Hash(Regex, String).new
        @uncountables = Uncountables.new
        @humans = Hash(Regex, String).new
        @acronyms = Hash(String, String).new
        @acronym_regex = /(?=a)b/
      end

      # Define a new acronym that should be recognized.
      #
      # Example:
      # ```
      # Wordsmith::Inflector.inflections.acronym("API")
      # Wordsmith::Inflector.camelize("API")   # => "API"
      # Wordsmith::Inflector.underscore("API") # => "api"
      # Wordsmith::Inflector.humanize("API")   # => "API"
      # Wordsmith::Inflector.titleize("API")   # => "API"
      # ```
      def acronym(word)
        @acronyms[word.downcase] = word
        @acronym_regex = /#{acronyms.values.join("|")}/
      end

      # Define a new pluralization rule, either using a pattern or string.
      #
      # Example with a `Regex` pattern:
      # ```
      # Wordsmith::Inflector.inflections.plural(/^goose(\S*)$/i, "geese\\1")
      # Wordsmith::Inflector.pluralize("goosebumps") # => "geesebumps"
      # ```
      #
      # Example with a `String`:
      # ```
      # Wordsmith::Inflector.inflections.plural("goosebumps", "geesebumps")
      # Wordsmith::Inflector.pluralize("goosebumps") # => "geesebumps"
      # ```
      def plural(rule : String | Regex, replacement : String)
        if rule.is_a?(String)
          @uncountables.delete(rule)
          rule = /#{rule}/
        end
        @uncountables.delete(replacement)
        new_plural = {rule => replacement}
        @plurals = @plurals.merge(new_plural)
      end

      # Define a new singularization rule, either using a pattern or string.
      #
      # Example with a `Regex` pattern:
      # ```
      # Wordsmith::Inflector.inflections.singular(/^(ox)en$/i, "\\1")
      # Wordsmith::Inflector.singularize("oxen") # => "ox"
      # ```
      #
      # Example with a `String`:
      # ```
      # Wordsmith::Inflector.inflections.singular("mice", "mouse")
      # Wordsmith::Inflector.singularize("mice") # => "mouse"
      # ```
      def singular(rule : String | Regex, replacement : String)
        if rule.is_a?(String)
          @uncountables.delete(rule)
          rule = /#{rule}/
        end
        @uncountables.delete(replacement)
        new_singular = {rule => replacement}
        @singulars = @singulars.merge(new_singular)
      end

      # Define a new irregular `String` with a direct translation between singular and plural form.
      #
      # Example:
      # ```
      # Wordsmith::Inflector.inflections.irregular("person", "people")
      # Wordsmith::Inflector.singularize("people") # => "person"
      # Wordsmith::Inflector.pluralize("person")   # => "people"
      # ```
      def irregular(singular : String, plural : String)
        @uncountables.delete(singular)
        @uncountables.delete(plural)

        s0 = singular[0]
        srest = singular[1..-1]

        p0 = plural[0]
        prest = plural[1..-1]

        if s0.upcase == p0.upcase
          plural(/(#{s0})#{srest}$/i, "\\1" + prest)
          plural(/(#{p0})#{prest}$/i, "\\1" + prest)

          singular(/(#{s0})#{srest}$/i, "\\1" + srest)
          singular(/(#{p0})#{prest}$/i, "\\1" + srest)
        else
          plural(/#{s0.upcase}(?i)#{srest}$/, p0.upcase + prest)
          plural(/#{s0.downcase}(?i)#{srest}$/, p0.downcase + prest)
          plural(/#{p0.upcase}(?i)#{prest}$/, p0.upcase + prest)
          plural(/#{p0.downcase}(?i)#{prest}$/, p0.downcase + prest)

          singular(/#{s0.upcase}(?i)#{srest}$/, s0.upcase + srest)
          singular(/#{s0.downcase}(?i)#{srest}$/, s0.downcase + srest)
          singular(/#{p0.upcase}(?i)#{prest}$/, s0.upcase + srest)
          singular(/#{p0.downcase}(?i)#{prest}$/, s0.downcase + srest)
        end
      end

      # Define a new uncountable `String` that should stay the same between singular and plural form.
      #
      # Example with a single `String`:
      # ```
      # Wordsmith::Inflector.inflections.uncountable("jedi")
      # Wordsmith::Inflector.singularize("jedi") # => "jedi"
      # Wordsmith::Inflector.pluralize("jedi")   # => "jedi"
      # ```
      #
      # Example with a single `String`:
      # ```
      # Wordsmith::Inflector.inflections.uncountable(%w(fish jedi))
      # Wordsmith::Inflector.singularize("jedi") # => "jedi"
      # Wordsmith::Inflector.pluralize("fish")   # => "fish"
      # ```
      def uncountable(*words)
        @uncountables.add(words.to_a)
      end

      # Define a new humanize rule, either using a pattern or string.
      #
      # Example with a `Regex` pattern:
      # ```
      # Wordsmith::Inflector.inflections.human(/^prefix_/i, "\\1")
      # Wordsmith::Inflector.humanize("prefix_request") # => "Request"
      # ```
      #
      # Example with a `String`:
      # ```
      # Wordsmith::Inflector.inflections.human("col_rpted_bugs", "Reported bugs")
      # Wordsmith::Inflector.humanize("col_rpted_bugs") # => "Reported bugs"
      # ```
      def human(rule : String | Regex, replacement : String)
        rule = /#{rule}/ if rule.is_a?(String)
        @humans = {rule => replacement}.merge(@humans)
      end

      # Remove all currently-stored Inflection rules, or a subset of rules.
      #
      # Subsets can be provided with the `scope` parameter, and can be any of:
      # * `:all`
      # * `:plurals`
      # * `:singulars`
      # * `:uncountables`
      # * `:humans`
      def clear(scope = :all)
        scopes = scope == :all ? [:plurals, :singulars, :uncountables, :humans] : [scope]

        scopes.each do |s|
          case s
          when :plurals
            @plurals = Hash(Regex, String).new
          when :singulars
            @singulars = Hash(Regex, String).new
          when :uncountables
            @uncountables = Uncountables.new
          when :humans
            @humans = Hash(Regex, String).new
          end
        end
      end
    end
  end
end
