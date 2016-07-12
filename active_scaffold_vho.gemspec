# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'active_scaffold/version'

Gem::Specification.new do |s|
  s.name = %q{active_scaffold_vho}
  s.version = ActiveScaffold::Version::STRING
  s.platform = Gem::Platform::RUBY
  s.authors = ["Many, see README"]
  s.description = %q{Save time and headaches, and create a more easily maintainable set of pages, with ActiveScaffold. ActiveScaffold handles all your CRUD (create, read, update, delete) user interface needs, leaving you more time to focus on more challenging (and interesting!) problems.}
  s.email = %q{activescaffold@googlegroups.com}
  s.extra_rdoc_files = [
      "README"
  ]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.homepage = %q{http://github.com/vhochstein/active_scaffold}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.summary = %q{Rails 3 Version of activescaffold supporting prototype and jquery}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.add_development_dependency(%q<shoulda>, [">= 0"])
  s.add_development_dependency(%q<bundler>, [">= 1.0.0"])
  s.add_development_dependency(%q<simplecov>, [">= 0"])

  s.add_runtime_dependency(%q<rails>, [">= 3.1.0"])
  s.add_runtime_dependency(%q<kaminari>)
end