require File.join(File.dirname(__FILE__), '..', 'lib', 'bean_counter.rb')

require 'test/unit'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class BeanCounterTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  alias :response :last_response
  alias :request  :last_request

  def app
    @app = BeanCounter.new
  end

  def test_hello_world
    get '/'
    assert response.ok?
    assert_equal 'Hello World!', response.body
  end
end