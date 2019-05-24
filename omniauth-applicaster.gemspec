# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-applicaster/version'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-applicaster"
  spec.version       = OmniAuth::Applicaster::VERSION
  spec.authors       = ["Neer Friedman"]
  spec.email         = ["neerfri@gmail.com"]
  spec.summary       = %q{Omniauth strategy for http://accounts.applicaster.com}
  spec.description   = %q{Omniauth strategy for http://accounts.applicaster.com}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1"
  spec.add_development_dependency "webmock"

  spec.add_dependency "omniauth-oauth2"
  spec.add_dependency "faraday", "~> 0.11"
  spec.add_dependency "oauth2", "> 1.3.1"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "excon"
  spec.add_dependency "virtus"
end
