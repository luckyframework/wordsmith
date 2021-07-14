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
    def pluralize(word)
      apply_inflections(word, inflections.plurals)
    end

    # Given a word, return the singular version of that word.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.singularize("sandals") # => "sandal"
    # Wordsmith::Inflector.singularize("people")  # => "person"
    # Wordsmith::Inflector.singularize("person")  # => "person"
    # ```
    def singularize(word)
      apply_inflections(word, inflections.singulars)
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
    def camelize(term, uppercase_first_letter = true)
      string = term.to_s
      string = if uppercase_first_letter
                 string.sub(/^[a-z\d]*/) do |match|
                   inflections.acronyms[match]? || match.capitalize
                 end
               else
                 string.sub(/^(?:#{inflections.acronym_regex}(?=\b|[A-Z_])|\w)/) do |match|
                   match.downcase
                 end
               end
      string = string.gsub(/(?:_|(\/))([a-z\d]*)/i) do |_string, match|
        "#{match[1]?}#{inflections.acronyms[match[2]]? || match[2].capitalize}"
      end
      string = string.gsub("/", "::")
      string
    end

    # Convert a given camel-case word to the underscored version of that word.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.underscore("ApplicationController") # => "application_controller"
    # ```
    def underscore(camel_cased_word)
      return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
      word = camel_cased_word.to_s.gsub("::", "/")
      word = word.gsub(/(?:(?<=([A-Za-z\d]))|\b)(#{inflections.acronym_regex})(?=\b|[^a-z])/) do |_string, match|
        "#{match[1]? && "_"}#{match[2].downcase}"
      end
      word = word.gsub(/([A-Z\d]+)([A-Z][a-z])/, "\\1_\\2")
      word = word.gsub(/([a-z\d])([A-Z])/, "\\1_\\2")
      word = word.tr("-", "_")
      word = word.downcase
      word
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
    def humanize(lower_case_and_underscored_word, capitalize = true, keep_id_suffix = false)
      result = lower_case_and_underscored_word.to_s.dup

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

    # Capitalize the first letter of a given word.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.upcase_first("lucky") # => "Lucky"
    # ```
    def upcase_first(string)
      string.size > 0 ? string[0].to_s.upcase + string[1..-1] : ""
    end

    # Convert a given word to the titleized version of that word, which generally means each word is capitalized.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.titleize("amazon web services") # => "Amazon Web Services"
    # ```
    def titleize(word, keep_id_suffix = false)
      humanize(underscore(word), keep_id_suffix: keep_id_suffix).gsub(/\b(?<!\w['’`])[a-z]/) do |match|
        match.capitalize
      end
    end

    # Convert a given class name to the database table name for that class.
    #
    # Examples:
    # ```
    # Wordsmith::Inflector.tableize("User")   # => "users"
    # Wordsmith::Inflector.tableize("Person") # => "people"
    # ```
    def tableize(class_name)
      pluralize(underscore(class_name))
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
    def classify(table_name)
      # strip out any leading schema name
      camelize(singularize(table_name.to_s.sub(/.*\./, "")))
    end

    # Convert a given underscore-separated word to the same word, separated by dashes.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.dasherize("post_office") # => "post-office"
    # ```
    def dasherize(underscored_word)
      underscored_word.tr("_", "-")
    end

    # Remove leading modules from a provided class name path.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.demodulize("Helpers::Mixins::User") # => "User"
    # ```
    def demodulize(path)
      path = path.to_s
      if i = path.rindex("::")
        path[(i + 2)..-1]
      else
        path
      end
    end

    # Remove any trailing constants from the provided path.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.deconstantize("Helpers::Mixins::User::FREE_TIER_COMMENTS") # => "Helpers::Mixins::User"
    # ```
    def deconstantize(path)
      path.to_s[0, path.rindex("::") || 0] # implementation based on the one in facets' Module#spacename
    end

    # Determine the foreign key representation of a given class name.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.foreign_key("Person") # => "person_id"
    # ```
    def foreign_key(class_name, separate_class_name_and_id_with_underscore = true)
      underscore(demodulize(class_name)) + (separate_class_name_and_id_with_underscore ? "_id" : "id")
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
    def ordinal(number)
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

    # Given a number, return the number with the correct ordinal suffix.
    #
    # Example:
    # ```
    # Wordsmith::Inflector.ordinalize(1) # => "1st"
    # Wordsmith::Inflector.ordinalize(2) # => "2nd"
    # Wordsmith::Inflector.ordinalize(3) # => "3rd"
    # Wordsmith::Inflector.ordinalize(4) # => "4th"
    # ```
    def ordinalize(number)
      "#{number}#{ordinal(number)}"
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
    def parameterize(content : String, separator : String? = "-", preserve_case : Bool = false)
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

    # Apply the previously-defined inflection rules to a given word.
    private def apply_inflections(word, rules)
      result = word.to_s.dup

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
  end
end
