# encoding: UTF-8
require 'test_helper'

# se testean las funcionalidades de la aplicación los decorators, queda como proyecto
class AppTest < Minitest::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  decorated = ['resource', 'request']

  def test_as_if_i_had_a_location(url)
    decorated.each { |one|  assert_equal {"from": "2013-11-13T11:00:00Z","to": "2013-11-13T12:00:00Z","status": "approved", "user": "sorgentini@gmail.com", "links": [ {"rel": "self","uri": "http://localhost:9292/algo"},{"rel": "booking","uri": "http://localhost:9292/algo/booking"} ]},   eval("#{one.Capitalize}Decorator.new(#{one.Capitalize}.first).as_if_i_had_a_location('http://www.example.org/'") }
  end
  
  def test_as_if_i_had_actions(url, *args)
    assert_equal 200, last_response.status
  end

  def test_as_if_i_were_json
    assert_equal 200, last_response.status
  end

  def test_as_if_i_were_hash
    assert_equal 200, last_response.status
  end

  def test_as_if_i_were_a_number
  end
end