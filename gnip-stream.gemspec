# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'gnip-stream/version'

Gem::Specification.new do |s|
  s.name        = 'gnip-stream'
  s.version     = GnipStream::VERSION
  s.authors     = ['Ryan Weald']
  s.email       = ['ryan@weald.com']
  s.homepage    = 'https://github.com/rweald/gnip-stream'
  s.summary     = 'A library to connect and stream data from the GNIP streaming API'
  s.description = ''
  s.license = 'MIT'

  s.rubyforge_project = 'gnip-stream'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = %w(lib vendor)

  s.add_development_dependency 'rspec', '~> 3.3'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'codeclimate-test-reporter'
  s.add_development_dependency 'dotenv'

  s.add_dependency 'em-http-request', '>= 1.0.3'
end
