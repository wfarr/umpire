require File.join(File.dirname(__FILE__), 'umpire', 'init.rb')
require File.join(File.dirname(__FILE__), 'umpire', 'redis.rb')

require 'sinatra'

$r = Redis.new
$redis = Redis::Namespace.new(:umpire, :redis => $r)

module Umpire
  class App < Sinatra::Base
    include Umpire::Redis

    set :views, File.dirname(__FILE__) + '/umpire/templates'
    
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

    # WE'RE ALL DEAD GTFO
    def porkchop_sandwiches(msg)
      return [500, msg]
    end
  end
end
