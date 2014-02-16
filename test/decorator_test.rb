# encoding: UTF-8
require 'test_helper'

# se testean las funcionalidades de la aplicación app.rb en /
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