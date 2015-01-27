# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'complete_payment_systems/version'

Gem::Specification.new do |spec|
  spec.name          = "complete_payment_systems"
  spec.version       = CompletePaymentSystems::VERSION
  spec.date          = Date.today.to_s
  spec.authors       = ["Epigene"]
  spec.email         = ["augusts.bautra@gmail.com"]
  spec.summary       = %q{A client for CPS (Complete Payment Systems) card payment service}
  spec.description   = %q{CPS (Complete Payment Systems) card payment service API in Ruby}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'unirest'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'nokogiri', '~> 1.6.6'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', "~> 3.1.0"
end
