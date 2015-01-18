require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rubwitter"
  gem.homepage = "http://github.com/gladimdim/rubwitter"
  gem.license = "MIT"
  gem.summary = "This gem will install twitter console application. Application will provide user with basic and very simple interface to communicate with twitter."
  gem.description = "Twitter console" 
  gem.email = "gladimdim@gmail.com"
  gem.authors = ["Dmitry Gladkiy"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
#  gem.add_runtime_dependency 'twitter_oauth'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

