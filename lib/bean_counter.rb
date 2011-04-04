require File.join(File.dirname(__FILE__), 'bean_counter', 'init.rb')

require 'sinatra'

$redis = Redis.new

class BeanCounter < Sinatra::Base
  get '/' do
    'Hello World!'
  end
  
  post '/:fqdn' do
    fqdn = params[:fqdn]
    if $redis.hexists 'counts', fqdn
      $redis.hincrby('counts', fqdn, 1)
    else
      $redis.hset 'counts', fqdn, 1
    end
    "#{$redis.hget 'counts', fqdn}"
  end
end