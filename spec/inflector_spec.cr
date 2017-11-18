require "./spec_helper"

require "../src/lucky_inflector/inflector/**"
require "../src/lucky_inflector/inflections"
require "./support/inflector_test_cases"

include InflectorTestCases

describe LuckyInflector::Inflector do
  describe "pluralize" do
    SingularToPlural.each do |singular, plural|
      it "should pluralize #{singular}" do
        LuckyInflector::Inflector.pluralize(singular).should eq plural
        LuckyInflector::Inflector.pluralize(singular.capitalize).should eq plural.capitalize
      end
    end

    it "should pluralize empty string" do
      LuckyInflector::Inflector.pluralize("").should eq ""
    end

    SingularToPlural.each do |singular, plural|
      it "should pluralize #{plural}" do
        LuckyInflector::Inflector.pluralize(plural).should eq plural
        LuckyInflector::Inflector.pluralize(plural.capitalize).should eq plural.capitalize
      end
    end
  end

  describe "singular" do
    SingularToPlural.each do |singular, plural|
      it "should singularize #{plural}" do
        LuckyInflector::Inflector.singularize(plural).should eq singular
        LuckyInflector::Inflector.singularize(plural.capitalize).should eq singular.capitalize
      end
    end

    SingularToPlural.each do |singular, plural|
      it "should singularize #{singular}" do
        LuckyInflector::Inflector.singularize(singular).should eq singular
        LuckyInflector::Inflector.singularize(singular.capitalize).should eq singular.capitalize
      end
    end
  end

  describe "camelize" do
    InflectorTestCases::CamelToUnderscore.each do |camel, underscore|
      it "should camelize #{underscore}" do
        LuckyInflector::Inflector.camelize(underscore).should eq camel
      end
    end

    it "should not capitalize" do
      LuckyInflector::Inflector.camelize("active_model", false).should eq "activeModel"
      LuckyInflector::Inflector.camelize("active_model/errors", false).should eq "activeModel::Errors"
    end

    it "test camelize with lower downcases the first letter" do
      LuckyInflector::Inflector.camelize("Capital", false).should eq "capital"
    end

    it "test camelize with underscores" do
      LuckyInflector::Inflector.camelize("Camel_Case").should eq "CamelCase"
    end
  end

  describe "underscore" do
    CamelToUnderscore.each do |camel, underscore|
      it "should underscore #{camel}" do
        LuckyInflector::Inflector.underscore(camel).should eq underscore
      end
    end

    CamelToUnderscoreWithoutReverse.each do |camel, underscore|
      it "should underscore without reverse #{camel}" do
        LuckyInflector::Inflector.underscore(camel).should eq underscore
      end
    end

    CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      it "should camelize with module #{underscore}" do
        LuckyInflector::Inflector.camelize(underscore).should eq camel
      end
    end

    CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      it "should underscore with slashes #{camel}" do
        LuckyInflector::Inflector.underscore(camel).should eq underscore
      end
    end
  end

  describe "humanize" do
    UnderscoreToHuman.each do |underscore, human|
      it "should humanize #{underscore}" do
        LuckyInflector::Inflector.humanize(underscore).should eq human
      end
    end

    UnderscoreToHumanWithoutCapitalize.each do |underscore, human|
      it "should not capitalize #{underscore}" do
        LuckyInflector::Inflector.humanize(underscore, capitalize: false).should eq human
      end
    end

    UnderscoreToHumanWithKeepIdSuffix.each do |underscore, human|
      it "should keep id suffix #{underscore}" do
        LuckyInflector::Inflector.humanize(underscore, keep_id_suffix: true).should eq human
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
        LuckyInflector::Inflector.upcase_first(from).should eq to
      end
    end
  end

  describe "titleize" do
    MixtureToTitleCase.each do |before, titleized|
      it "should titleize mixture to title case #{before}" do
        LuckyInflector::Inflector.titleize(before).should eq titleized
      end
    end

    MixtureToTitleCaseWithKeepIdSuffix.each do |before, titleized|
      it "should titleize with keep id suffix mixture to title case #{before}" do
        LuckyInflector::Inflector.titleize(before, keep_id_suffix: true).should eq titleized
      end
    end
  end

  describe "tableize" do
    ClassNameToTableName.each do |class_name, table_name|
      it "should tableize #{class_name}" do
        LuckyInflector::Inflector.tableize(class_name).should eq table_name
      end
    end
  end

  describe "classify" do
    ClassNameToTableName.each do |class_name, table_name|
      it "should classify #{table_name}" do
        LuckyInflector::Inflector.classify(table_name).should eq class_name
        LuckyInflector::Inflector.classify("table_prefix." + table_name).should eq class_name
      end
    end

    it "should classify with symbol" do
      LuckyInflector::Inflector.classify(:foo_bars).should eq "FooBar"
    end

    it "should classify with leading schema name" do
      LuckyInflector::Inflector.classify("schema.foo_bar").should eq "FooBar"
    end
  end

  describe "dasherize" do
    UnderscoresToDashes.each do |underscored, dasherized|
      it "should dasherize #{underscored}" do
        LuckyInflector::Inflector.dasherize(underscored).should eq dasherized
      end
    end

    UnderscoresToDashes.each_key do |underscored|
      it "should underscore as reverse of dasherize #{underscored}" do
        LuckyInflector::Inflector.underscore(LuckyInflector::Inflector.dasherize(underscored)).should eq underscored
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
        LuckyInflector::Inflector.demodulize(from).should eq to
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
        LuckyInflector::Inflector.deconstantize(from).should eq to
      end
    end
  end

  describe "foreign_key" do
    ClassNameToForeignKeyWithUnderscore.each do |klass, foreign_key|
      it "should foreign key #{klass}" do
        LuckyInflector::Inflector.foreign_key(klass).should eq foreign_key
      end
    end

    ClassNameToForeignKeyWithoutUnderscore.each do |klass, foreign_key|
      it "should foreign key without underscore #{klass}" do
        LuckyInflector::Inflector.foreign_key(klass, false).should eq foreign_key
      end
    end
  end

  describe "ordinal" do
    OrdinalNumbers.each do |number, ordinalized|
      it "should ordinal #{number}" do
        (number + LuckyInflector::Inflector.ordinal(number)).should eq ordinalized
      end
    end
  end

  describe "ordinalize" do
    OrdinalNumbers.each do |number, ordinalized|
      it "should ordinalize #{number}" do
        LuckyInflector::Inflector.ordinalize(number).should eq ordinalized
      end
    end
  end

  describe "irregularities" do
    Irregularities.each do |singular, plural|
      it "should handle irregularity between #{singular} and #{plural}" do
        LuckyInflector::Inflector.inflections.irregular(singular, plural)
        LuckyInflector::Inflector.singularize(plural).should eq singular
        LuckyInflector::Inflector.pluralize(singular).should eq plural
      end
    end

    Irregularities.each do |singular, plural|
      it "should pluralize irregularity #{plural} should be the same" do
        LuckyInflector::Inflector.inflections.irregular(singular, plural)
        LuckyInflector::Inflector.pluralize(plural).should eq plural
      end
    end

    Irregularities.each do |singular, plural|
      it "should singularize irregularity #{singular} should be the same" do
        LuckyInflector::Inflector.inflections.irregular(singular, plural)
        LuckyInflector::Inflector.singularize(singular).should eq singular
      end
    end
  end

  describe "acronyms" do
    LuckyInflector::Inflector.inflections.acronym("API")
    LuckyInflector::Inflector.inflections.acronym("HTML")
    LuckyInflector::Inflector.inflections.acronym("HTTP")
    LuckyInflector::Inflector.inflections.acronym("RESTful")
    LuckyInflector::Inflector.inflections.acronym("W3C")
    LuckyInflector::Inflector.inflections.acronym("PhD")
    LuckyInflector::Inflector.inflections.acronym("RoR")
    LuckyInflector::Inflector.inflections.acronym("SSL")

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
        LuckyInflector::Inflector.camelize(under).should eq camel
        LuckyInflector::Inflector.camelize(camel).should eq camel
        LuckyInflector::Inflector.underscore(under).should eq under
        LuckyInflector::Inflector.underscore(camel).should eq under
        LuckyInflector::Inflector.titleize(under).should eq title
        LuckyInflector::Inflector.titleize(camel).should eq title
        LuckyInflector::Inflector.humanize(under).should eq human
      end
    end

    it "should handle acronym override" do
      LuckyInflector::Inflector.inflections.acronym("API")
      LuckyInflector::Inflector.inflections.acronym("LegacyApi")

      LuckyInflector::Inflector.camelize("legacyapi").should eq "LegacyApi"
      LuckyInflector::Inflector.camelize("legacy_api").should eq "LegacyAPI"
      LuckyInflector::Inflector.camelize("some_legacyapi").should eq "SomeLegacyApi"
      LuckyInflector::Inflector.camelize("nonlegacyapi").should eq "Nonlegacyapi"
    end

    it "should handle acronyms camelize lower" do
      LuckyInflector::Inflector.inflections.acronym("API")
      LuckyInflector::Inflector.inflections.acronym("HTML")

      LuckyInflector::Inflector.camelize("html_api", false).should eq "htmlAPI"
      LuckyInflector::Inflector.camelize("htmlAPI", false).should eq "htmlAPI"
      LuckyInflector::Inflector.camelize("HTMLAPI", false).should eq "htmlAPI"
    end

    it "should handle underscore acronym sequence" do
      LuckyInflector::Inflector.inflections.acronym("API")
      LuckyInflector::Inflector.inflections.acronym("JSON")
      LuckyInflector::Inflector.inflections.acronym("HTML")

      LuckyInflector::Inflector.underscore("JSONHTMLAPI").should eq "json_html_api"
    end
  end

  describe "clear" do
    it "should clear all" do
      # ensure any data is present
      LuckyInflector::Inflector.inflections.plural(/(quiz)$/i, "\\1zes")
      LuckyInflector::Inflector.inflections.singular(/(database)s$/i, "\\1")
      LuckyInflector::Inflector.inflections.uncountable("series")
      LuckyInflector::Inflector.inflections.human("col_rpted_bugs", "Reported bugs")

      LuckyInflector::Inflector.inflections.clear :all

      LuckyInflector::Inflector.inflections.plurals.empty?.should be_true
      LuckyInflector::Inflector.inflections.singulars.empty?.should be_true
      LuckyInflector::Inflector.inflections.uncountables.empty?.should be_true
      LuckyInflector::Inflector.inflections.humans.empty?.should be_true
    end

    it "should clear with default" do
      # ensure any data is present
      LuckyInflector::Inflector.inflections.plural(/(quiz)$/i, "\\1zes")
      LuckyInflector::Inflector.inflections.singular(/(database)s$/i, "\\1")
      LuckyInflector::Inflector.inflections.uncountable("series")
      LuckyInflector::Inflector.inflections.human("col_rpted_bugs", "Reported bugs")

      LuckyInflector::Inflector.inflections.clear

      LuckyInflector::Inflector.inflections.plurals.empty?.should be_true
      LuckyInflector::Inflector.inflections.singulars.empty?.should be_true
      LuckyInflector::Inflector.inflections.uncountables.empty?.should be_true
      LuckyInflector::Inflector.inflections.humans.empty?.should be_true
    end
  end

  describe "humans" do
    it "should humanize by rule" do
      LuckyInflector::Inflector.inflections.human(/_cnt$/i, "\\1_count")
      LuckyInflector::Inflector.inflections.human(/^prefx_/i, "\\1")

      LuckyInflector::Inflector.humanize("jargon_cnt").should eq "Jargon count"
      LuckyInflector::Inflector.humanize("prefx_request").should eq "Request"
    end

    it "should humanize by string" do
      LuckyInflector::Inflector.inflections.human("col_rpted_bugs", "Reported bugs")

      LuckyInflector::Inflector.humanize("col_rpted_bugs").should eq "Reported bugs"
      LuckyInflector::Inflector.humanize("COL_rpted_bugs").should eq "Col rpted bugs"
    end

    it "should humanize with acronyms" do
      LuckyInflector::Inflector.inflections.acronym("LAX")
      LuckyInflector::Inflector.inflections.acronym("SFO")

      LuckyInflector::Inflector.humanize("LAX ROUNDTRIP TO SFO").should eq "LAX roundtrip to SFO"
      LuckyInflector::Inflector.humanize("LAX ROUNDTRIP TO SFO", capitalize: false).should eq "LAX roundtrip to SFO"
      LuckyInflector::Inflector.humanize("lax roundtrip to sfo").should eq "LAX roundtrip to SFO"
      LuckyInflector::Inflector.humanize("lax roundtrip to sfo", capitalize: false).should eq "LAX roundtrip to SFO"
      LuckyInflector::Inflector.humanize("Lax Roundtrip To Sfo").should eq "LAX roundtrip to SFO"
      LuckyInflector::Inflector.humanize("Lax Roundtrip To Sfo", capitalize: false).should eq "LAX roundtrip to SFO"
    end
  end
end
