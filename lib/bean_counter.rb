require File.join(File.dirname(__FILE__), 'bean_counter', 'init.rb')

require 'sinatra'

$redis = Redis.new

class BeanCounter < Sinatra::Base
  get '/' do
    'Hello World!'
  end
end