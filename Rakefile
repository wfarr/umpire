require 'lib/umpire.rb'

require 'minitest/unit'
require 'rack'
require 'rack/test'
require 'rack/server'

task :default do
  # just run tests, nothing fancy
  Dir["test/*.rb"].sort.each { |test|  load test }
  MiniTest::Unit.autorun
end