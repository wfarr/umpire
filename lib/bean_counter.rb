require File.join(File.dirname(__FILE__), 'bean_counter', 'init.rb')

require 'sinatra'

$redis = Redis.new

class BeanCounter < Sinatra::Base
  set :views, File.dirname(__FILE__) + '/bean_counter/templates'
  
  get '/' do
    @all = all_counts
    erb :index
  end

  post '/:fqdn' do
    fqdn = params[:fqdn]
    if count_exists?(fqdn)
      inc_count(fqdn)
    else
      new_count(fqdn)
    end
    "#{fetch_count(fqdn)}"
  end

  get '/:fqdn' do
    fqdn = params[:fqdn]
    if count_exists?(fqdn)
      "#{fetch_count(fqdn)}"
    else
      porkchop_sandwiches('dne')
    end
  end

  # redis helpers
  def count_exists?(fqdn)
    $redis.hexists 'counts', fqdn
  end

  def all_counts
    $redis.hgetall 'counts'
  end

  def fetch_count(fqdn)
    $redis.hget 'counts', fqdn
  end

  def inc_count(fqdn)
    $redis.hincrby('counts', fqdn, 1)
  end

  def new_count(fqdn)
    $redis.hset 'counts', fqdn, 1
  end

  # WE'RE ALL DEAD GTFO
  def porkchop_sandwiches(msg)
    [500, msg]
  end
end