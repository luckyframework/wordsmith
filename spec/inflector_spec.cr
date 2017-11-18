require "./spec_helper"

require "../src/lucky_support/inflector/**"
require "../src/lucky_support/inflections"
require "./support/inflector_test_cases"

include InflectorTestCases

describe LuckySupport::Inflector do
  describe "pluralize" do
    SingularToPlural.each do |singular, plural|
      it "should pluralize #{singular}" do
        LuckySupport::Inflector.pluralize(singular).should eq plural
        LuckySupport::Inflector.pluralize(singular.capitalize).should eq plural.capitalize
      end
    end

    it "should pluralize empty string" do
      LuckySupport::Inflector.pluralize("").should eq ""
    end

    SingularToPlural.each do |singular, plural|
      it "should pluralize #{plural}" do
        LuckySupport::Inflector.pluralize(plural).should eq plural
        LuckySupport::Inflector.pluralize(plural.capitalize).should eq plural.capitalize
      end
    end
  end

  describe "singular" do
    SingularToPlural.each do |singular, plural|
      it "should singularize #{plural}" do
        LuckySupport::Inflector.singularize(plural).should eq singular
        LuckySupport::Inflector.singularize(plural.capitalize).should eq singular.capitalize
      end
    end

    SingularToPlural.each do |singular, plural|
      it "should singularize #{singular}" do
        LuckySupport::Inflector.singularize(singular).should eq singular
        LuckySupport::Inflector.singularize(singular.capitalize).should eq singular.capitalize
      end
    end
  end

  describe "camelize" do
    InflectorTestCases::CamelToUnderscore.each do |camel, underscore|
      it "should camelize #{underscore}" do
        LuckySupport::Inflector.camelize(underscore).should eq camel
      end
    end

    it "should not capitalize" do
      LuckySupport::Inflector.camelize("active_model", false).should eq "activeModel"
      LuckySupport::Inflector.camelize("active_model/errors", false).should eq "activeModel::Errors"
    end

    it "test camelize with lower downcases the first letter" do
      LuckySupport::Inflector.camelize("Capital", false).should eq "capital"
    end

    it "test camelize with underscores" do
      LuckySupport::Inflector.camelize("Camel_Case").should eq "CamelCase"
    end
  end

  describe "underscore" do
    CamelToUnderscore.each do |camel, underscore|
      it "should underscore #{camel}" do
        LuckySupport::Inflector.underscore(camel).should eq underscore
      end
    end

    CamelToUnderscoreWithoutReverse.each do |camel, underscore|
      it "should underscore without reverse #{camel}" do
        LuckySupport::Inflector.underscore(camel).should eq underscore
      end
    end

    CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      it "should camelize with module #{underscore}" do
        LuckySupport::Inflector.camelize(underscore).should eq camel
      end
    end

    CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      it "should underscore with slashes #{camel}" do
        LuckySupport::Inflector.underscore(camel).should eq underscore
      end
    end
  end

  describe "humanize" do
    UnderscoreToHuman.each do |underscore, human|
      it "should humanize #{underscore}" do
        LuckySupport::Inflector.humanize(underscore).should eq human
      end
    end

    UnderscoreToHumanWithoutCapitalize.each do |underscore, human|
      it "should not capitalize #{underscore}" do
        LuckySupport::Inflector.humanize(underscore, capitalize: false).should eq human
      end
    end

    UnderscoreToHumanWithKeepIdSuffix.each do |underscore, human|
      it "should keep id suffix #{underscore}" do
        LuckySupport::Inflector.humanize(underscore, keep_id_suffix: true).should eq human
      end
    end
  end

  describe "upcase_first" do
    it "should upcase first" do
      tests = {
        "what a Lovely Day" => "What a Lovely Day",
        "w"                 => "W",
        ""                  => "",
      }

      tests.each do |from, to|
        LuckySupport::Inflector.upcase_first(from).should eq to
      end
    end
  end

  describe "titleize" do
    MixtureToTitleCase.each do |before, titleized|
      it "should titleize mixture to title case #{before}" do
        LuckySupport::Inflector.titleize(before).should eq titleized
      end
    end

    MixtureToTitleCaseWithKeepIdSuffix.each do |before, titleized|
      it "should titleize with keep id suffix mixture to title case #{before}" do
        LuckySupport::Inflector.titleize(before, keep_id_suffix: true).should eq titleized
      end
    end
  end

  describe "tableize" do
    ClassNameToTableName.each do |class_name, table_name|
      it "should tableize #{class_name}" do
        LuckySupport::Inflector.tableize(class_name).should eq table_name
      end
    end
  end

  describe "classify" do
    ClassNameToTableName.each do |class_name, table_name|
      it "should classify #{table_name}" do
        LuckySupport::Inflector.classify(table_name).should eq class_name
        LuckySupport::Inflector.classify("table_prefix." + table_name).should eq class_name
      end
    end

    it "should classify with symbol" do
      LuckySupport::Inflector.classify(:foo_bars).should eq "FooBar"
    end

    it "should classify with leading schema name" do
      LuckySupport::Inflector.classify("schema.foo_bar").should eq "FooBar"
    end
  end

  describe "dasherize" do
    UnderscoresToDashes.each do |underscored, dasherized|
      it "should dasherize #{underscored}" do
        LuckySupport::Inflector.dasherize(underscored).should eq dasherized
      end
    end

    UnderscoresToDashes.each_key do |underscored|
      it "should underscore as reverse of dasherize #{underscored}" do
        LuckySupport::Inflector.underscore(LuckySupport::Inflector.dasherize(underscored)).should eq underscored
      end
    end
  end

  describe "demodulize" do
    demodulize_tests = {
      "MyApplication::Billing::Account" => "Account",
      "Account"                         => "Account",
      "::Account"                       => "Account",
      ""                                => "",
    }

    demodulize_tests.each do |from, to|
      it "should demodulize #{from}" do
        LuckySupport::Inflector.demodulize(from).should eq to
      end
    end
  end

  describe "deconstantize" do
    deconstantize_tests = {
      "MyApplication::Billing::Account"   => "MyApplication::Billing",
      "::MyApplication::Billing::Account" => "::MyApplication::Billing",
      "MyApplication::Billing"            => "MyApplication",
      "::MyApplication::Billing"          => "::MyApplication",
      "Account"                           => "",
      "::Account"                         => "",
      ""                                  => "",
    }

    deconstantize_tests.each do |from, to|
      it "should deconstantize #{from}" do
        LuckySupport::Inflector.deconstantize(from).should eq to
      end
    end
  end

  describe "foreign_key" do
    ClassNameToForeignKeyWithUnderscore.each do |klass, foreign_key|
      it "should foreign key #{klass}" do
        LuckySupport::Inflector.foreign_key(klass).should eq foreign_key
      end
    end

    ClassNameToForeignKeyWithoutUnderscore.each do |klass, foreign_key|
      it "should foreign key without underscore #{klass}" do
        LuckySupport::Inflector.foreign_key(klass, false).should eq foreign_key
      end
    end
  end

  describe "ordinal" do
    OrdinalNumbers.each do |number, ordinalized|
      it "should ordinal #{number}" do
        (number + LuckySupport::Inflector.ordinal(number)).should eq ordinalized
      end
    end
  end

  describe "ordinalize" do
    OrdinalNumbers.each do |number, ordinalized|
      it "should ordinalize #{number}" do
        LuckySupport::Inflector.ordinalize(number).should eq ordinalized
      end
    end
  end

  describe "irregularities" do
    Irregularities.each do |singular, plural|
      it "should handle irregularity between #{singular} and #{plural}" do
        LuckySupport::Inflector.inflections.irregular(singular, plural)
        LuckySupport::Inflector.singularize(plural).should eq singular
        LuckySupport::Inflector.pluralize(singular).should eq plural
      end
    end

    Irregularities.each do |singular, plural|
      it "should pluralize irregularity #{plural} should be the same" do
        LuckySupport::Inflector.inflections.irregular(singular, plural)
        LuckySupport::Inflector.pluralize(plural).should eq plural
      end
    end

    Irregularities.each do |singular, plural|
      it "should singularize irregularity #{singular} should be the same" do
        LuckySupport::Inflector.inflections.irregular(singular, plural)
        LuckySupport::Inflector.singularize(singular).should eq singular
      end
    end
  end

  describe "acronyms" do
    LuckySupport::Inflector.inflections.acronym("API")
    LuckySupport::Inflector.inflections.acronym("HTML")
    LuckySupport::Inflector.inflections.acronym("HTTP")
    LuckySupport::Inflector.inflections.acronym("RESTful")
    LuckySupport::Inflector.inflections.acronym("W3C")
    LuckySupport::Inflector.inflections.acronym("PhD")
    LuckySupport::Inflector.inflections.acronym("RoR")
    LuckySupport::Inflector.inflections.acronym("SSL")

    #  camelize             underscore            humanize              titleize
    [
      ["API", "api", "API", "API"],
      ["APIController", "api_controller", "API controller", "API Controller"],
      ["Nokogiri::HTML", "nokogiri/html", "Nokogiri/HTML", "Nokogiri/HTML"],
      ["HTTPAPI", "http_api", "HTTP API", "HTTP API"],
      ["HTTP::Get", "http/get", "HTTP/get", "HTTP/Get"],
      ["SSLError", "ssl_error", "SSL error", "SSL Error"],
      ["RESTful", "restful", "RESTful", "RESTful"],
      ["RESTfulController", "restful_controller", "RESTful controller", "RESTful Controller"],
      ["Nested::RESTful", "nested/restful", "Nested/RESTful", "Nested/RESTful"],
      ["IHeartW3C", "i_heart_w3c", "I heart W3C", "I Heart W3C"],
      ["PhDRequired", "phd_required", "PhD required", "PhD Required"],
      ["IRoRU", "i_ror_u", "I RoR u", "I RoR U"],
      ["RESTfulHTTPAPI", "restful_http_api", "RESTful HTTP API", "RESTful HTTP API"],
      ["HTTP::RESTful", "http/restful", "HTTP/RESTful", "HTTP/RESTful"],
      ["HTTP::RESTfulAPI", "http/restful_api", "HTTP/RESTful API", "HTTP/RESTful API"],
      ["APIRESTful", "api_restful", "API RESTful", "API RESTful"],

      # misdirection
      ["Capistrano", "capistrano", "Capistrano", "Capistrano"],
      ["CapiController", "capi_controller", "Capi controller", "Capi Controller"],
      ["HttpsApis", "https_apis", "Https apis", "Https Apis"],
      ["Html5", "html5", "Html5", "Html5"],
      ["Restfully", "restfully", "Restfully", "Restfully"],
      ["RoRails", "ro_rails", "Ro rails", "Ro Rails"],
    ].each do |words|
      camel, under, human, title = words
      it "should handle acronym #{camel}" do
        LuckySupport::Inflector.camelize(under).should eq camel
        LuckySupport::Inflector.camelize(camel).should eq camel
        LuckySupport::Inflector.underscore(under).should eq under
        LuckySupport::Inflector.underscore(camel).should eq under
        LuckySupport::Inflector.titleize(under).should eq title
        LuckySupport::Inflector.titleize(camel).should eq title
        LuckySupport::Inflector.humanize(under).should eq human
      end
    end

    it "should handle acronym override" do
      LuckySupport::Inflector.inflections.acronym("API")
      LuckySupport::Inflector.inflections.acronym("LegacyApi")

      LuckySupport::Inflector.camelize("legacyapi").should eq "LegacyApi"
      LuckySupport::Inflector.camelize("legacy_api").should eq "LegacyAPI"
      LuckySupport::Inflector.camelize("some_legacyapi").should eq "SomeLegacyApi"
      LuckySupport::Inflector.camelize("nonlegacyapi").should eq "Nonlegacyapi"
    end

    it "should handle acronyms camelize lower" do
      LuckySupport::Inflector.inflections.acronym("API")
      LuckySupport::Inflector.inflections.acronym("HTML")

      LuckySupport::Inflector.camelize("html_api", false).should eq "htmlAPI"
      LuckySupport::Inflector.camelize("htmlAPI", false).should eq "htmlAPI"
      LuckySupport::Inflector.camelize("HTMLAPI", false).should eq "htmlAPI"
    end

    it "should handle underscore acronym sequence" do
      LuckySupport::Inflector.inflections.acronym("API")
      LuckySupport::Inflector.inflections.acronym("JSON")
      LuckySupport::Inflector.inflections.acronym("HTML")

      LuckySupport::Inflector.underscore("JSONHTMLAPI").should eq "json_html_api"
    end
  end

  describe "clear" do
    it "should clear all" do
      # ensure any data is present
      LuckySupport::Inflector.inflections.plural(/(quiz)$/i, "\\1zes")
      LuckySupport::Inflector.inflections.singular(/(database)s$/i, "\\1")
      LuckySupport::Inflector.inflections.uncountable("series")
      LuckySupport::Inflector.inflections.human("col_rpted_bugs", "Reported bugs")

      LuckySupport::Inflector.inflections.clear :all

      LuckySupport::Inflector.inflections.plurals.empty?.should be_true
      LuckySupport::Inflector.inflections.singulars.empty?.should be_true
      LuckySupport::Inflector.inflections.uncountables.empty?.should be_true
      LuckySupport::Inflector.inflections.humans.empty?.should be_true
    end

    it "should clear with default" do
      # ensure any data is present
      LuckySupport::Inflector.inflections.plural(/(quiz)$/i, "\\1zes")
      LuckySupport::Inflector.inflections.singular(/(database)s$/i, "\\1")
      LuckySupport::Inflector.inflections.uncountable("series")
      LuckySupport::Inflector.inflections.human("col_rpted_bugs", "Reported bugs")

      LuckySupport::Inflector.inflections.clear

      LuckySupport::Inflector.inflections.plurals.empty?.should be_true
      LuckySupport::Inflector.inflections.singulars.empty?.should be_true
      LuckySupport::Inflector.inflections.uncountables.empty?.should be_true
      LuckySupport::Inflector.inflections.humans.empty?.should be_true
    end
  end

  describe "humans" do
    it "should humanize by rule" do
      LuckySupport::Inflector.inflections.human(/_cnt$/i, "\\1_count")
      LuckySupport::Inflector.inflections.human(/^prefx_/i, "\\1")

      LuckySupport::Inflector.humanize("jargon_cnt").should eq "Jargon count"
      LuckySupport::Inflector.humanize("prefx_request").should eq "Request"
    end

    it "should humanize by string" do
      LuckySupport::Inflector.inflections.human("col_rpted_bugs", "Reported bugs")

      LuckySupport::Inflector.humanize("col_rpted_bugs").should eq "Reported bugs"
      LuckySupport::Inflector.humanize("COL_rpted_bugs").should eq "Col rpted bugs"
    end

    it "should humanize with acronyms" do
      LuckySupport::Inflector.inflections.acronym("LAX")
      LuckySupport::Inflector.inflections.acronym("SFO")

      LuckySupport::Inflector.humanize("LAX ROUNDTRIP TO SFO").should eq "LAX roundtrip to SFO"
      LuckySupport::Inflector.humanize("LAX ROUNDTRIP TO SFO", capitalize: false).should eq "LAX roundtrip to SFO"
      LuckySupport::Inflector.humanize("lax roundtrip to sfo").should eq "LAX roundtrip to SFO"
      LuckySupport::Inflector.humanize("lax roundtrip to sfo", capitalize: false).should eq "LAX roundtrip to SFO"
      LuckySupport::Inflector.humanize("Lax Roundtrip To Sfo").should eq "LAX roundtrip to SFO"
      LuckySupport::Inflector.humanize("Lax Roundtrip To Sfo", capitalize: false).should eq "LAX roundtrip to SFO"
    end
  end
end
