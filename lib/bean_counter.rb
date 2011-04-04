require File.join(File.dirname(__FILE__), 'bean_counter', 'init.rb')

require 'sinatra'

$redis = Redis.new

class BeanCounter < Sinatra::Base
  set :views, File.dirname(__FILE__) + '/bean_counter/templates'
  
  get '/' do
    @all = $redis.hgetall 'counts'
    erb :index
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

  get '/:fqdn' do
    fqdn = params[:fqdn]
    if $redis.hexists 'counts', fqdn
      "#{$redis.hget 'counts', fqdn}"
    else
      porkchop_sandwiches('dne')
    end
  end

  def porkchop_sandwiches(msg)
    [500, msg]
  end
end