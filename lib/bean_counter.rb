require File.join(File.dirname(__FILE__), 'bean_counter', 'init.rb')

require 'sinatra'

$redis = Redis.new

class BeanCounter < Sinatra::Base
  set :views, File.dirname(__FILE__) + '/bean_counter/templates'
  
  get '/' do
    @all = all_counts
    erb :index
  end

  post '/new' do
    @fqdn = params[:fqdn]
    if count_exists?(@fqdn)
      porkchop_sandwiches('already on the roster')
    else
      new_count(@fqdn)
      redirect to("/#{@fqdn}")
    end
  end

  post '/incr' do
    @fqdn = params[:fqdn]
    if count_exists?(@fqdn)
      inc_count(@fqdn)
      redirect to("/#{@fqdn}")
    else
      porkchop_sandwiches('not on the team, chief')
    end
  end

  post '/destroy' do
    @fqdn = params[:fqdn]
    if count_exists?(@fqdn)
      del_count(@fqdn)
      redirect to('/')
    else
      porkchop_sandwiches('is this guy even real?')
    end
  end

  get '/:fqdn' do
    @fqdn = params[:fqdn]
    if count_exists?(@fqdn)
      @count = fetch_count(@fqdn)
      erb :fqdn
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
  
  def del_count(fqdn)
    $redis.hdel 'counts', fqdn
  end

  # WE'RE ALL DEAD GTFO
  def porkchop_sandwiches(msg)
    return [500, msg]
  end
end