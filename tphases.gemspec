# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tphases/version'

Gem::Specification.new do |gem|
  gem.name    = "tphases"
  gem.version = Tphases::VERSION
  gem.authors = ["Charles Finkel"]
  gem.email   = ["charles.finkel@gmail.com"]

  description     = %q{TPhases (Transactional Phases) is a support framework that helps you build your Rails request life cycles into read-only and write-only phases.}
  gem.description = description
  gem.summary     = description
  gem.homepage    = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'activesupport'

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'debugger'
  gem.add_development_dependency 'sqlite3'
  gem.add_development_dependency 'activerecord'
  gem.add_development_dependency 'pry'
end
