require "./inflections"

module Wordsmith
  module Inflector
    extend self

    # Given a word, return the plural version of that word.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.pluralize("sandal") # => "sandals"
    # Wordsmith::Inflector.pluralize("person") # => "people"
    # Wordsmith::Inflector.pluralize("people") # => "people"
    # ```
    def pluralize(word : String) : String
      apply_inflections(word, inflections.plurals)
    end

    # Given an IO and a word, it appends the plural version of that word
    # to the IO.
    #
    # Example:
    # ```
    # io = IO::Memory.new
    # Wordsmith::Inflector.pluralize(io, "person")
    # io.to_s # => "people"
    def pluralize(io : IO, word : String) : Nil
      apply_inflections(io, word, inflections.plurals)
    end

    # Given a word, return the singular version of that word.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.singularize("sandals") # => "sandal"
    # Wordsmith::Inflector.singularize("people")  # => "person"
    # Wordsmith::Inflector.singularize("person")  # => "person"
    # ```
    def singularize(word : String) : String
      apply_inflections(word, inflections.singulars)
    end

    # Given an IO and a word, it appends the singular version of that word
    # to the IO.
    #
    # Example:
    # ```
    # io = IO::Memory.new
    # Wordsmith::Inflector.singularize(io, "people")
    # io.to_s # => "person"
    def singularize(io : IO, word : String) : Nil
      apply_inflections(io, word, inflections.singulars)
    end

    # Convert a given word to the camel-case version of that word.
    #
    # Optionally, a second parameter can be provided that controls whether or not the first letter is capitalized.
    #
    # Examples:
    # ```
    # Wordsmith::Inflector.camelize("application_controller")                                # => "ApplicationController"
    # Wordsmith::Inflector.camelize("application_controller", uppercase_first_letter: false) # => "applicationController"
    # ```
    def camelize(term : String, uppercase_first_letter : Bool = true) : String
      string = if uppercase_first_letter
                 term.sub(/^[a-z\d]*/) do |match|
                   inflections.acronyms[match]? || match.capitalize
                 end
               else
                 term.sub(/^(?:#{inflections.acronym_regex}(?=\b|[A-Z_])|\w)/) do |match|
                   match.downcase
                 end
               end
      string = string.gsub(/(?:_|(\/))([a-z\d]*)/i) do |_string, match|
        "#{match[1]?}#{inflections.acronyms[match[2]]? || match[2].capitalize}"
      end
      string = string.gsub("/", "::")
      string
    end

    # :ditto:
    def camelize(io : IO, term : String, uppercase_first_letter : Bool = true) : Nil
      io << camelize(term, uppercase_first_letter)
    end

    # Convert a given camel-case word to the underscored version of that word.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.underscore("ApplicationController") # => "application_controller"
    # ```
    def underscore(camel_cased_word : String) : String
      return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
      word = camel_cased_word.gsub("::", "/")
        .gsub(/(?:(?<=([A-Za-z\d]))|\b)(#{inflections.acronym_regex})(?=\b|[^a-z])/) do |_string, match|
          "#{match[1]? && "_"}#{match[2].downcase}"
        end
        .gsub(/([A-Z\d]+)([A-Z][a-z])/, "\\1_\\2")
        .gsub(/([a-z\d])([A-Z])/, "\\1_\\2")
        .tr("-", "_")
        .downcase
    
      word
    end

    # :ditto:
    def underscore(io : IO, camel_cased_word : String) : Nil
      io << underscore(camel_cased_word)
    end

    # Convert a given word to the human-friendly version of that word.
    #
    # Capitalization and whether or not to retain an `_id` suffix can be controlled with optional parameters.
    #
    # Examples:
    # ```
    # Wordsmith::Inflector.humanize("employee_id")                       # => "Employee"
    # Wordsmith::Inflector.humanize("employee_id", capitalize: false)    # => "employee"
    # Wordsmith::Inflector.humanize("employee_id", keep_id_suffix: true) # => "Employee id"
    # ```
    def humanize(lower_case_and_underscored_word : String, capitalize : Bool = true, keep_id_suffix : Bool = false) : String
      result = lower_case_and_underscored_word.dup

      inflections.humans.each { |rule, replacement|
        if result.index(rule)
          result = result.sub(rule, replacement)
          break
        end
      }

      result = result.sub(/\A_+/, "")
      unless keep_id_suffix
        result = result.sub(/_id\z/, "")
      end
      result = result.tr("_", " ")

      result = result.gsub(/([a-z\d]*)/i) do |match|
        "#{inflections.acronyms[match.downcase]? || match.downcase}"
      end

      if capitalize
        result = result.sub(/\A\w/, &.upcase)
      end

      result
    end

    # :ditto:
    def humanize(io : IO, lower_case_and_underscored_word : String, capitalize : Bool = true, keep_id_suffix : Bool = false) : Nil
      io << humanize(lower_case_and_underscored_word, capitalize, keep_id_suffix)
    end

    # Capitalize the first letter of a given word.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.upcase_first("lucky") # => "Lucky"
    # ```
    def upcase_first(string : String) : String
      string.size > 0 ? string[0].upcase + string[1..-1] : ""
    end

    # :ditto:
    def upcase_first(io : IO, string : String) : Nil
      io << upcase_first(string)
    end

    # Convert a given word to the titleized version of that word, which generally means each word is capitalized.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.titleize("amazon web services") # => "Amazon Web Services"
    # ```
    def titleize(word : String, keep_id_suffix : Bool = false) : String
      humanize(underscore(word), keep_id_suffix: keep_id_suffix).gsub(/\b(?<!\w['’`])[a-z]/) do |match|
        match.capitalize
      end
    end

    # :ditto:
    def titleize(io : IO, word : String, keep_id_suffix : Bool = false) : Nil
      io << titleize(word, keep_id_suffix)
    end

    # Convert a given class name to the database table name for that class.
    #
    # Examples:
    # ```
    # Wordsmith::Inflector.tableize("User")   # => "users"
    # Wordsmith::Inflector.tableize("Person") # => "people"
    # ```
    def tableize(class_name : String) : String
      pluralize(underscore(class_name))
    end

    # :ditto:
    def tableize(io : IO, class_name : String) : Nil
      io << tableize(class_name)
    end

    # Convert a given table name to the class name for that table.
    #
    # Examples:
    # ```
    # Wordsmith::Inflector.classify("users")               # => "User"
    # Wordsmith::Inflector.classify("people")              # => "Person"
    # Wordsmith::Inflector.classify("schema.users")        # => "User"
    # Wordsmith::Inflector.classify("schema.public.users") # => "User"
    # ```
    def classify(table_name : String | Symbol) : String
      # strip out any leading schema name
      camelize(singularize(table_name.to_s.sub(/.*\./, "")))
    end

    # :ditto:
    def classify(io : IO, table_name : String | Symbol) : Nil
      io << classify(table_name)
    end

    # Convert a given underscore-separated word to the same word, separated by dashes.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.dasherize("post_office") # => "post-office"
    # ```
    def dasherize(underscored_word : String) : String
      underscored_word.tr("_", "-")
    end

    # :ditto:
    def dasherize(io : IO, underscored_word : String) : Nil
      io << dasherize(underscored_word)
    end

    # Remove leading modules from a provided class name path.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.demodulize("Helpers::Mixins::User") # => "User"
    # ```
    def demodulize(path : String) : String
      if i = path.rindex("::")
        path[(i + 2)..-1]
      else
        path
      end
    end

    # :ditto:
    def demodulize(io : IO, path : String) : Nil
      io << demodulize(path)
    end

    # Remove any trailing constants from the provided path.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.deconstantize("Helpers::Mixins::User::FREE_TIER_COMMENTS") # => "Helpers::Mixins::User"
    # ```
    def deconstantize(path : String) : String
      path[0, path.rindex("::") || 0] # implementation based on the one in facets' Module#spacename
    end

    # :ditto:
    def deconstantize(io : IO, path : String) : Nil
      io << deconstantize(path)
    end

    # Determine the foreign key representation of a given class name.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.foreign_key("Person") # => "person_id"
    # ```
    def foreign_key(class_name : String, separate_class_name_and_id_with_underscore : Bool = true) : String
      underscore(demodulize(class_name)) + (separate_class_name_and_id_with_underscore ? "_id" : "id")
    end

    # :ditto:
    def foreign_key(io : IO, class_name : String, separate_class_name_and_id_with_underscore : Bool = true) : Nil
      io << foreign_key(class_name, separate_class_name_and_id_with_underscore)
    end

    # Determine the ordinal suffix for a given number.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.ordinal(1) # => "st"
    # Wordsmith::Inflector.ordinal(2) # => "nd"
    # Wordsmith::Inflector.ordinal(3) # => "rd"
    # Wordsmith::Inflector.ordinal(4) # => "th"
    # ```
    # TODO: This should only take an Int
    def ordinal(number : Int | String) : String
      abs_number = number.to_i.abs

      if (11..13).includes?(abs_number % 100)
        "th"
      else
        case abs_number % 10
        when 1; "st"
        when 2; "nd"
        when 3; "rd"
        else    "th"
        end
      end
    end

    # :ditto:
    def ordinal(io : IO, number : Int | String) : Nil
      io << ordinal(number)
    end

    # Given a number, return the number with the correct ordinal suffix.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.ordinalize(1) # => "1st"
    # Wordsmith::Inflector.ordinalize(2) # => "2nd"
    # Wordsmith::Inflector.ordinalize(3) # => "3rd"
    # Wordsmith::Inflector.ordinalize(4) # => "4th"
    # ```
    # TODO: This should only take an Int
    def ordinalize(number : Int | String) : String
      "#{number}#{ordinal(number)}"
    end

    # :ditto:
    def ordinalize(io : IO, number : Int | String) : Nil
      io << ordinalize(number)
    end

    # Convert the given string to a parameter-friendly version.
    #
    # The used separator and whether or not to preserve the original object case can be controlled through optional parameters.
    #
    # Examples:
    # ```
    # Wordsmith::Inflector.parameterize("Admin/product")                       # => "admin-product"
    # Wordsmith::Inflector.parameterize("Admin::Product", separator: "_")      # => "admin_product"
    # Wordsmith::Inflector.parameterize("Admin::Product", preserve_case: true) # => "Admin-Product"
    # ```
    def parameterize(content : String, separator : String? = "-", preserve_case : Bool = false) : String
      parameterized_string = content.gsub(/[^a-z0-9\-_]+/i, separator)

      unless separator.nil? || separator.empty?
        if separator == "-"
          re_duplicate_separator = /-{2,}/
          re_leading_trailing_separator = /^-|-$/i
        else
          re_sep = Regex.escape(separator)
          re_duplicate_separator = /#{re_sep}{2,}/
          re_leading_trailing_separator = /^#{re_sep}|#{re_sep}$/i
        end
        parameterized_string = parameterized_string.gsub(re_duplicate_separator, separator)
        parameterized_string = parameterized_string.gsub(re_leading_trailing_separator, "")
      end

      parameterized_string = parameterized_string.downcase unless preserve_case
      parameterized_string
    end

    # :ditto:
    def parameterize(io : IO, content : String, separator : String? = "-", preserve_case : Bool = false) : Nil
      io << parameterize(content, separator, preserve_case)
    end

    # Apply the previously-defined inflection rules to a given word.
    private def apply_inflections(word : String, rules : Enumerable) : String
      result = word.dup

      if result.empty? || inflections.uncountables.uncountable?(result)
        result
      else
        rules.to_a.reverse.each { |rule, replacement|
          if result.index(rule)
            result = result.sub(rule, replacement)
            break
          end
        }
        result
      end
    end

    private def apply_inflections(io : IO, word : String, rules : Enumerable) : Nil
      io << apply_inflections(word, rules)
    end
  end
end
