# encoding: UTF-8
require 'sinatra/reloader'
require 'date'
require 'time'
require_relative 'model/resource'
require_relative 'model/request'
require_relative 'decorator/resource_decorator'
require_relative 'decorator/request_decorator'

ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3',
  database: 'db/test.sqlite3'
 )

SECONDS_IN_A_DAY = 86400