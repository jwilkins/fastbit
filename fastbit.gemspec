# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastbit/version'

Gem::Specification.new do |spec|
  spec.name          = "fastbit"
  spec.version       = Fastbit::VERSION
  spec.authors       = ["Jonathan Wilkins"]
  spec.email         = ["jwilkins@bitland.net"]
  spec.description   = %q{ffi interface to fastbit}
  spec.summary       = %q{Fastbit compressed bitmap indexe}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "ffi"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
