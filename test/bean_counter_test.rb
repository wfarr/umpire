require File.join(File.dirname(__FILE__), '..', 'lib', 'bean_counter.rb')

require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class BeanCounterTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  alias :response :last_response
  alias :request  :last_request

  def app
    BeanCounter.new
  end

  def test_hello_world
    get '/'
    assert response.ok?
    assert_equal 'Hello World!', response.body
  end
  
  def test_connect_to_redis
    assert_equal $redis.ping, 'PONG'
  end

  def test_create_new_hitter
    clear_fqdn_count
    post '/foo.bar.baz.com'
    assert response.ok?
    assert_equal '1', response.body
    clear_fqdn_count
  end

  def test_check_existing_hitter
    set_fqdn_count
    get '/foo.bar.baz.com'
    assert response.ok?
    assert_equal '13', response.body
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