# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'familysearch/gedcomx/version'

Gem::Specification.new do |spec|
  spec.name          = "familysearch-gedcomx"
  spec.version       = FamilySearch::Gedcomx::VERSION
  spec.authors       = ["Jimmy Zimmerman"]
  spec.email         = ["jimmy.zimmerman@gmail.com"]
  spec.description   = %q{A structured object model for the application/x-fs-v1+json media type.}
  spec.summary       = %q{A structured object model for the application/x-fs-v1+json media type}
  spec.homepage      = "https://github.com/jimmyz/familysearch-gedcomx-rb"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "hashie", "~> 2.0.5"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
