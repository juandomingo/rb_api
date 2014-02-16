# encoding: UTF-8
require 'sinatra/reloader'
require_relative 'model/resource'
require_relative 'model/request'
require_relative 'decorator/resource_decorator'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db/test.sqlite3'
 )
