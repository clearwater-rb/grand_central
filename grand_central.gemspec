# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grand_central/version'

Gem::Specification.new do |spec|
  spec.name          = "grand_central"
  spec.version       = GrandCentral::VERSION
  spec.authors       = ["Jamie Gaskins"]
  spec.email         = ["jgaskins@gmail.com"]

  spec.summary       = %q{State and action management for Ruby apps}
  spec.homepage      = "https://github.com/clearwater-rb/grand_central"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
