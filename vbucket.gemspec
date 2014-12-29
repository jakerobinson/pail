# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vbucket/version'

Gem::Specification.new do |spec|
  spec.name          = 'vbucket'
  spec.version       = Vbucket::VERSION
  spec.authors       = ['jakerobinson']
  spec.email         = ['jaker@vbucket.io']
  spec.description   = %q{A RESTful interface for block level storage}
  spec.summary       = %q{vBucket is a simple Ruby app to provide a REST API for your Linux block level storage}
  spec.homepage      = 'http://vbucket.io'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'sinatra'
  spec.add_runtime_dependency 'sinatra-contrib'
  spec.add_runtime_dependency 'rack-ssl'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
