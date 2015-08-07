require 'bundler'
Bundler.setup

require 'dotenv'
Dotenv.load

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'rspec'
