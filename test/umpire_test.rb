require File.join(File.dirname(__FILE__), '..', 'lib', 'umpire.rb')

require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class UmpireTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  alias :response :last_response
  alias :request  :last_request

  def app
    Umpire::App.new
  end

  def test_index_with_no_fqdns
    clear_fqdn_count
    get '/'
    assert response.ok?
    assert_match 'The count is nothing', response.body
  end

  def test_index_with_fqdns
    set_fqdn_count
    get '/'
    assert response.ok?
    assert_match 'foo.bar.baz.com', response.body
    assert_match '13', response.body
    clear_fqdn_count
  end

  def test_connect_to_redis
    assert_equal $redis.ping, 'PONG'
  end

  def test_create_new_hitter
    clear_fqdn_count
    post '/new', :fqdn => 'foo.bar.baz.com'
    assert 302, response.status
    clear_fqdn_count
  end

  def test_create_new_hitter_from_fqdn
    clear_fqdn_count
    post '/incr', :fqdn => 'foo.bar.baz.com'
    assert 302, response.status
    clear_fqdn_count
  end

  def test_destroy_existing_hitter
    set_fqdn_count
    post '/destroy', :fqdn => 'foo.bar.baz.com'
    assert 302, response.status
    clear_fqdn_count
  end

  def test_destroy_non_existing_hitter
    post '/destroy', :fqdn => 'foo.bar.baz.com'
    assert 500, response.status
    assert_equal 'is this guy even real?', response.body
  end

  def test_check_existing_hitter
    set_fqdn_count
    get '/foo.bar.baz.com'
    assert response.ok?
    assert_match 'Umpire | foo.bar.baz.com', response.body
    assert_match 'This guy\'s got 13 strikes!', response.body
    clear_fqdn_count
  end

  def test_check_nonexistent_hitter
    get '/bang.com'
    refute response.ok?
    assert_equal 'dne', response.body
  end

  def clear_fqdn_count
    $redis.hdel 'counts', 'foo.bar.baz.com'
  end

  def set_fqdn_count
    $redis.hset 'counts', 'foo.bar.baz.com', 13
  end
end
