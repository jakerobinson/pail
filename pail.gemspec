# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pail/version'

Gem::Specification.new do |spec|
  spec.name          = 'pail'
  spec.version       = Pail::VERSION
  spec.authors       = ['jakerobinson']
  spec.email         = ['jaker@pailproject.io']
  spec.description   = %q{A REST API for your files}
  spec.summary       = %q{Pail is a simple REST API for your files}
  spec.homepage      = 'http://pailproject.io'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'sinatra'
  spec.add_runtime_dependency 'sinatra-contrib'
  spec.add_runtime_dependency 'rack-ssl'
  spec.add_runtime_dependency 'nokogiri'
  spec.add_runtime_dependency 'ffi-xattr'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
